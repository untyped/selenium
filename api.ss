#lang scheme

(require (for-syntax scheme/match
                     "api-internal.ss")
         net/url
         "config.ss"
         "core.ss")

; Syntax -----------------------------------------

; symbol -> symbol
(define-for-syntax (schemify-id sym)

  ; string -> string
  (define (replace str)
    (format "-~a" (string-downcase str)))
  
  (string->symbol (format "sel-~a" (regexp-replace* #px"[A-Z]" (symbol->string sym) replace))))

; syntax -> syntax
(define-syntax (define/provide-api stx)
  (define expand-command
    (match-lambda
      [(list javascript-id arity return-type)
       (with-syntax ([javascript-id javascript-id]
                     [(arg ...)          (for/list ([i (in-range 0 arity)])
                                           (datum->syntax #f (string->symbol (format "arg~a" i))))]
                     [(arg-contract ...) (for/list ([i (in-range 0 arity)])
                                           #'string?)]
                     [scheme-id          (datum->syntax stx (schemify-id javascript-id))]
                     [parse-result       (case return-type
                                           [(void)        #'parse-void]
                                           [(string)      #'parse-string]
                                           [(string-list) #'parse-string-list]
                                           [(base64)      #'parse-base64]
                                           [(number)      #'parse-number]
                                           [(boolean)     #'parse-boolean]
                                           [else          (error "bad api return type" return-type)])]
                     [result-contract    (case return-type
                                           [(void)        #'void?]
                                           [(string)      #'string?]
                                           [(string-list) #'(listof string?)]
                                           [(base64)      #'bytes?]
                                           [(number)      #'number?]
                                           [(boolean)     #'boolean?]
                                           [else          (error "bad api return type" return-type)])])
         #`(begin (define (scheme-id arg ...)
                    (parse-result (do-command 'javascript-id arg ...)))
                  (provide/contract [scheme-id (-> arg-contract ... result-contract)])))]))
  
  (syntax-case stx ()
    [(_) #`(begin #,@(map expand-command api-commands))]))

; Actual API -------------------------------------

(define/provide-api)

; -> string
(define (sel-start)
  (let* ([config     (config-ref)]
         [session-id (parse-string (do-command 'getNewBrowserSession
                                               (selenium-config-browser config)
                                               (url->string (selenium-config-browser-url config))))])
    (set-selenium-config-session-id! (current-selenium-config) session-id)
    (void)))

(provide/contract
 [sel-start (-> void?)])

