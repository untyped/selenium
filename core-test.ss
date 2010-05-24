#lang scheme

(require "test-base.ss")

(require net/base64
         "core.ss")

; Helpers ----------------------------------------

(define-check (check-parser parser input output)
  (check-equal? (parser (make-raw-result (string->bytes/utf-8 (format "OK,~a" input)))) output))

; Tests ------------------------------------------

(define/provide-test-suite core-tests
  
  (test-case "parse-string"
    (check-parser parse-string "abc" "abc")
    (check-parser parse-string "" "")
    (check-exn
     exn:fail?
     (lambda ()
       (parse-string (make-raw-result "BAD")))))
  
  (test-case "parse-string-list"
    (check-parser parse-string-list "a,b,c" (list "a" "b" "c"))
    (check-parser parse-string-list "a,b," (list "a" "b" ""))
    (check-parser parse-string-list "" (list ""))
    (check-parser parse-string-list "a\\,b,c" (list "a,b" "c"))
    (check-parser parse-string-list "a\\\\b,c" (list "a\\b" "c"))
    (check-parser parse-string-list "a\\.b,c" (list "a\\.b" "c")))
  
  (test-case "parse-number"
    (check-parser parse-number "1.23" 1.23)
    (check-parser parse-number "-1.23" -1.23))
  
  (test-case "parse-boolean"
    (check-parser parse-boolean "true" #t)
    (check-parser parse-boolean "false" #f))
  
  (test-case "parse-base64"
    (check-equal? (parse-base64 (make-raw-result (bytes-append #"OK," (base64-encode #"abcde"))))
                  #"abcde")))
