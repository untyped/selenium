#lang scheme

(require net/base64
         net/url
         "config.ss"
         (planet untyped/unlib:3/debug))

; (struct bytes)
(define-struct raw-result (data) #:transparent)

; symbol (U string #f) (U string #f) [#:config selenium-config] -> any
(define (do-command command
                    [target #f]
                    [value #f]
                    #:config [config (config-ref)])
  
  (when (print-selenium-commands?)
    (display "[selenium] sent ")
    (when command
      (display command))
    (when target
      (printf " ~a" target))
    (when value
      (printf " ~a" value))
    (newline))
  
  (let* ([base-url   (selenium-config-server-url config)]
         [session-id (selenium-config-session-id config)]
         [url        (make-url (url-scheme base-url)
                               (url-user base-url)
                               (url-host base-url)
                               (url-port base-url)
                               (url-path-absolute? base-url)
                               (url-path base-url)
                               (append (list (cons 'cmd (symbol->string command)))
                                       (if target
                                           (list (cons '|1| target))
                                           null)
                                       (if value
                                           (list (cons '|2| value))
                                           null)
                                       (if session-id
                                           (list (cons 'sessionId session-id))
                                           null)
                                       (url-query base-url))
                               (url-fragment base-url))]
         [ans-port   (get-impure-port url)]
         ; 'spool' is just a hack: read-line waits for hte port to have contents, ensuring
         ; that there are bytes on the port before the real reading begins (see 'ans' below).
         ; Here, we just spool off all the header lines until we reach an empty line.
         ; Then, the port has byte-ready? and the content of teh response can be read off.
         [spool      (let loop () 
                       (let ([line (read-bytes-line ans-port 'return-linefeed)])
                         ;(printf "~s~n" line)
                         (unless (or (eof-object? line)
                                     (bytes=? line #""))
                           (loop))))]
         ; here we buffer the content for immediate return (not waiting for TCP port to close)
         [buff       (make-bytes 4096 0)]
         [ans        (let loop ([accum #""])
                       (if (byte-ready? ans-port)
                           (match (read-bytes-avail! buff ans-port)
                             [(? eof-object?)   accum]
                             [(? number? count) (loop (bytes-append accum (subbytes buff 0 count)))]
                             [other             (error "read unexpected data from input-port" other)])
                           accum))])
    
    (when (print-selenium-commands?)
      (display "[selenium] received ")
      (if (> (bytes-length ans) 80)
          (begin (display (subbytes ans 0 80))
                 (display "..."))
          (begin (display ans)))
      (newline))
    
    (close-input-port ans-port)
    (make-raw-result ans)))

; raw-result -> string
(define (parse-bytes result)
  
  (let* ([data (raw-result-data result)]
         [fail (lambda ()
                 (when (pause-on-selenium-command-failure?)
                   (printf "[selenium] command failed: ~a~n" data)
                   (printf "press ENTER to continue~n")
                   (read-line))
                 (error "[selenium] command failed" data))])
    
    (if (= (bytes-length data) 2)
        (if (equal? data #"OK") #"" (fail))
        (cond [(equal? (subbytes data 0 3) #"OK,")
               (subbytes data 3)]
              [(regexp-match #rx#"^Timed out after" data)
               (if (ignore-selenium-command-timeouts?) #"" (fail))]
              [else (fail)]))))

; raw-result -> string
(define (parse-void result)
  ; Parse the result anyway to trigger pause-on-selenium-command-failure? functionality:
  (parse-bytes result)
  (void))

; raw-result -> string
(define (parse-string result)
  (bytes->string/utf-8 (parse-bytes result)))

; raw-result -> (listof string)
(define (parse-string-list result)
  (let loop ([chars       (string->list (parse-string result))]
             [escaped?    #f]
             [part-accum  null]
             [parts-accum null])
    (match chars
      [(list) (reverse (cons (list->string (reverse part-accum)) parts-accum))]
      [(list-rest curr rest)
       (match curr
         [#\\ (if escaped?
                  (loop rest #f (cons #\\ part-accum) parts-accum)
                  (loop rest #t part-accum parts-accum))]
         [#\, (if escaped?
                  (loop rest #f (list* #\, part-accum) parts-accum)
                  (loop rest #f null (cons (list->string (reverse part-accum)) parts-accum)))]
         [_   (if escaped?
                  (loop rest #f (list* curr #\\ part-accum) parts-accum)
                  (loop rest #f (cons curr part-accum) parts-accum))])])))

; raw-result -> number
(define (parse-number result)
  (string->number (parse-string result)))

; raw-result -> boolean
(define (parse-boolean result)
  (match (parse-string result)
    ["true" #t]
    ["false" #f]))

; raw-result -> bytes
; Parses base64 encoded byte data.
(define (parse-base64 result)
  (base64-decode (parse-bytes result)))

; -> selenium-config
(define (config-ref)
  (or (current-selenium-config)
      (error "selenium config not set")))

; Provides ---------------------------------------

(provide/contract
 [struct raw-result ([data bytes?])]
 [do-command        (->* (symbol?)
                         ((or/c string? #f)
                          (or/c string? #f)
                          #:config selenium-config?)
                         raw-result?)]
 [parse-void        (-> raw-result? void?)]
 [parse-string      (-> raw-result? string?)]
 [parse-string-list (-> raw-result? (listof string?))]
 [parse-number      (-> raw-result? number?)]
 [parse-boolean     (-> raw-result? boolean?)]
 [parse-base64      (-> raw-result? bytes?)]
 [config-ref        (-> selenium-config?)])
