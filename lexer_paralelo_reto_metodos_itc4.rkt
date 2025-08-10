#lang racket

(require "./lexer_seq_reto_metodos_itc4.rkt")

(define (call/times f . args)
  (let-values ([(_ cpu real gc) (time-apply f args)])
    (values cpu real gc)))

(define-syntax-rule (times form ...)
  (call/times (thunk form ...)))

(define (analyze-c++-code code-snippets)
  ;(displayln #\.)
  (make-list 1000000 #f)
  (define tokens (tokenize-lines code-snippets))
  (for-each displayln tokens)
)


; Función para análisis secuencial
(define (sequential-analysis code-snippets)
  (map analyze-c++-code code-snippets) (displayln #\!))

; Función para análisis en paralelo. Aquí, "Futures" y "Touch" nos permiten automatizar la ejecución en varios procesadores. También, "code-snippets" es una lista de códigos para analizar
(define (parallel-analysis code-snippets)
  (define futures (map (lambda (code) (future (lambda () (analyze-c++-code code)))) code-snippets))
  (map touch futures) (displayln #\!))

; Función para medir el tiempo
(define (main)
  (define code-snippets (list "./file1.cpp" "./file2.cpp" "./file3.cpp" "./file5.cpp"))
  ;; Ejecución secuencial
  (define-values (t1 t2 t3 t4)
    (time-apply (lambda () (sequential-analysis code-snippets)) '()))
  (displayln "-------------------------------------------")
  (displayln (format "Tiempo de análisis secuencial: ~a ms" t3))

  ;; Ejecución paralela
  (define-values (tp1 tp2 tp3)
    (times (parallel-analysis code-snippets)))
  (displayln "-------------------------------------------")
  (displayln (format "Tiempo de análisis paralelo: ~a ms" tp3))
)

(main)