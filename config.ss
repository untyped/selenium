#lang scheme

(require net/url)

(define-struct selenium-config
  (server-url browser browser-url session-id timeout)
  #:mutable
  #:transparent)

; string (U string url) [string] [natural] [natural] -> selenium-config
(define (create-selenium-config browser browser-url [host "localhost"] [port 4444] [timeout 30000])
  (make-selenium-config (string->url (format "http://~a:~a/selenium-server/driver/" host port))
                        browser
                        (if (string? browser-url)
                            (string->url browser-url)
                            browser-url)
                        #f
                        timeout))


(define current-selenium-config
  (make-parameter #f))

(define print-selenium-commands?
  (make-parameter #f))

(define pause-on-selenium-command-failure?
  (make-parameter #f))

(define ignore-selenium-command-timeouts?
  (make-parameter #f))

; Provides ---------------------------------------

(provide/contract
 [struct selenium-config             ([server-url  url?]
                                      [browser     string?]
                                      [browser-url url?]
                                      [session-id  (or/c string? #f)]
                                      [timeout     natural-number/c])]
 [create-selenium-config             (->* (string? (or/c string? url?))
                                          (string? natural-number/c natural-number/c)
                                          selenium-config?)]
 [current-selenium-config            (parameter/c (or/c selenium-config? #f))]
 [print-selenium-commands?           (parameter/c boolean?)]
 [pause-on-selenium-command-failure? (parameter/c boolean?)]
 [ignore-selenium-command-timeouts?  (parameter/c boolean?)])
