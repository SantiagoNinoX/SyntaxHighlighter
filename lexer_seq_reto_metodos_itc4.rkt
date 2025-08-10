#lang racket
(require parser-tools/lex)
(require (prefix-in : parser-tools/lex-sre))

(define calc-lexer
  (lexer
   
   ;; TIPOS
   [(:: (:or "int" "float" "bool" "char" "double" "string" "void")) (cons '(V-TYPE) (calc-lexer input-port))]


   ;; Condicionales
   ["if"      (cons '(IF) (calc-lexer input-port))]
   ["else"    (cons '(ELSE) (calc-lexer input-port))]
   ["switch"    (cons '(SWITCH) (calc-lexer input-port))]
   ["case"    (cons '(CASE) (calc-lexer input-port))]
   ["default"    (cons '(DEFAULT) (calc-lexer input-port))]
   ["break"    (cons '(BREAK) (calc-lexer input-port))]

   ;; Ciclos
   ["while"   (cons '(WHILE) (calc-lexer input-port))]
   ["for"     (cons '(FOR) (calc-lexer input-port))]
   ["do"    (cons '(DO) (calc-lexer input-port))]

   ;; Operadores lógicos y relacionales y aritmeticos
   [(:: (:or "==" "!=" "<=" "<" ">=" ">")) (cons '(REL-OP) (calc-lexer input-port))]
   [(:: (:or "&&" "||" "!")) (cons '(LOG-OP) (calc-lexer input-port))]
   [(:: (:or "+" "-" "*" "/" "=" "%")) (cons '(MATH-OP) (calc-lexer input-port))]
   [(:: (:or "++" "--")) (cons '(INCREM-OP) (calc-lexer input-port))]

   ;; Puntuacion
   [#\(       (cons '(LPAR) (calc-lexer input-port))]
   [#\)       (cons '(RPAR) (calc-lexer input-port))]
   [#\{       (cons '(LBRACE) (calc-lexer input-port))]
   [#\}       (cons '(RBRACE) (calc-lexer input-port))]
   [#\[       (cons '(LCORCH) (calc-lexer input-port))]
   [#\]       (cons '(RCORCH) (calc-lexer input-port))]
   [#\;       (cons '(SEMI) (calc-lexer input-port))]
   [#\:       (cons '(COLON) (calc-lexer input-port))]
   [#\#       (cons '(GATO) (calc-lexer input-port))]
   [(:: "//" (:* (complement #\newline))) (calc-lexer input-port)]
   ;["<<"       (cons '(LCOCO) (calc-lexer input-port))]
   ;[">>"       (cons '(RCOCO) (calc-lexer input-port))]
   [","       (cons '(COMA) (calc-lexer input-port))]
   ["."       (cons '(DOT) (calc-lexer input-port))]
   ["'"       (cons '(COMILLAS) (calc-lexer input-port))]

   ;; Sistema
   ["main"     (cons '(SYSTEM-MAIN) (calc-lexer input-port))]
   ["cout"     (cons '(SYSTEM-COUT) (calc-lexer input-port))]
   ["cin"     (cons '(SYSTEM-CIN) (calc-lexer input-port))]
   ["endl"     (cons '(SYSTEM-ENDL) (calc-lexer input-port))]
   ["include"     (cons '(SYSTEM-INCLUDE) (calc-lexer input-port))]
   ["<iostream>"     (cons '(SYSTEM-IOSTREAM) (calc-lexer input-port))]
   ["<string>"     (cons '(SYSTEM-STRING) (calc-lexer input-port))]
   ["using namespace std;"     (cons '(SYSTEM-NAMESPACE) (calc-lexer input-port))]
   [(:: (:or "#pragma once" "ifdef" "define" "endif"))(cons `(DIRECTIVE ,lexeme) (calc-lexer input-port))]
   ["return"  (cons '(RETURN) (calc-lexer input-port))]
   ["h"   (cons '(ACHE) (calc-lexer input-port))]
   ["cpp"   (cons '(CPP) (calc-lexer input-port))]
   ["class"   (cons '(CLASS) (calc-lexer input-port))]
   ["this->"  (cons '(THIS) (calc-lexer input-port))]
   ["new"  (cons '(NEW) (calc-lexer input-port))]

   ;; Numeros positivos o negativos
   [(:: (:? #\-) (:+ (char-range #\0 #\9)))(cons `(INT, (string->number lexeme))(calc-lexer input-port))]

   ;[(:: #\" (:* (complement #\")) #\") (cons 'STRING (calc-lexer input-port))] ;;String

   ;; Bools
   [(:: (:or "true" "false"))(cons `(BOOLEAN ,lexeme) (calc-lexer input-port))]

   ;; Flotantes
   [(:: (:? #\-) (:+ (char-range #\0 #\9)) (:* whitespace) "." (:* whitespace) (:+ (char-range #\0 #\9)) (:* whitespace) "f")
    (cons `(FLOAT, lexeme)(calc-lexer input-port))]

   ;; Espacios blancos ignorados
   [whitespace
    ; =>
    (calc-lexer input-port)]

   [(union #\space #\newline) (calc-lexer input-port)]
   [(eof)'()]

   ;; Palabras clave de clase y visibilidad
   ["cpp"   (cons '(CPP) (calc-lexer input-port))]
   ["class"   (cons '(CLASS) (calc-lexer input-port))]
   [(:: (:or "public" "private" "protected"))(cons `(ACCESS-TYPE ,lexeme) (calc-lexer input-port))]
   ["~" (cons '(TILDE) (calc-lexer input-port))] ;; para destructores

   ;; Parametros
   [(:: "(" (:* whitespace)
        (:? (:: (:or "int" "float" "string" "char" "bool")(:+ whitespace)(:+ (union (char-range #\a #\z)(char-range #\A #\Z)(char-range #\0 #\9) #\_ #\-))
                  (:* whitespace)(:* (:: "," (:* whitespace) (:or "int" "float" "string" "char" "bool")(:+ whitespace)
                      (:+ (union (char-range #\a #\z)(char-range #\A #\Z)(char-range #\0 #\9)#\_ #\-))(:* whitespace)))))")")
    (cons '(PARAM) (calc-lexer input-port))]

   ;; 7. Clase con cuerpo
[(:: "class" (:* whitespace)(:or (char-range #\a #\z)(char-range #\A #\Z))(:+ (union (char-range #\a #\z)(char-range #\A #\Z)(char-range #\0 #\9) #\_ #\-))(:* whitespace)
    "{"(:* whitespace)
    ;; cuerpo de la clase: 0 o más declaraciones conocidas
    (:* (:: (:* whitespace)(:or
          ;; reutilizamos las reglas ya definidas como expresiones
          ;; en lugar de analizarlas individualmente aquí
          ;; usamos patrones de cadenas que empaten sus formas
          ;; esto no valida semánticamente, pero sí reconoce el patrón
          ;; Access modifiers
          (:: (:or "public" "private" "protected") (:* whitespace) ":")
          ;; Variable declaration
          (:: (:or "int" "float" "string" "char" "bool") (:* whitespace)(char-range #\a #\z)(:+ (union (char-range #\a #\z)(char-range #\A #\Z)(char-range #\0 #\9) #\_ #\-))
              (:? (:: "[" (:+ (char-range #\0 #\9)) "]"))
              (:? (:: "," (:* whitespace) (char-range #\a #\z)(:+ (union (char-range #\a #\z)(char-range #\A #\Z)(char-range #\0 #\9) #\_ #\-))
                    (:? (:: "[" (:+ (char-range #\0 #\9)) "]"))))(:* whitespace) ";")
          ;; Constructor
          (:: (:+ (union (char-range #\a #\z)(char-range #\A #\Z)(char-range #\0 #\9)#\_ #\-))"(" (:* whitespace)
              (:? (:: (:or "int" "float" "string" "char" "bool")(:+ whitespace)(:+ (union (char-range #\a #\z)(char-range #\A #\Z)(char-range #\0 #\9) #\_ #\-))
                  (:* whitespace)(:* (:: "," (:* whitespace) (:or "int" "float" "string" "char" "bool")(:+ whitespace)
                      (:+ (union (char-range #\a #\z)(char-range #\A #\Z)(char-range #\0 #\9)#\_ #\-))(:* whitespace)))))")" (:* whitespace) ";")
          ;; Destructor
          (:: "~" (:* whitespace)(:+ (union (char-range #\a #\z)(char-range #\A #\Z)(char-range #\0 #\9)#\_ #\-))(:* whitespace) "(" (:* whitespace) ")" (:* whitespace) ";")
          ;; Getter
          (:: (:or "int" "float" "string" "char" "bool" "void") (:* whitespace)"get" (:+ (union (char-range #\a #\z) (char-range #\A #\Z)(char-range #\0 #\9) #\_ #\-))
              (:* whitespace) "(" (:* whitespace) ")" (:* whitespace) ";")
          ;; Setter
          (:: (:or "int" "float" "string" "char" "bool" "void") (:* whitespace)"set" (:+ (union (char-range #\a #\z) (char-range #\A #\Z)(char-range #\0 #\9) #\_ #\-))
              (:* whitespace) "(" (:* whitespace)(:? (:: (:or "int" "float" "string" "char" "bool")(:+ whitespace)
                      (:+ (union (char-range #\a #\z)(char-range #\A #\Z)(char-range #\0 #\9) #\_ #\-))(:* whitespace))) ")" (:* whitespace) ";")
          ;; Method
          (:: (:or "int" "float" "string" "char" "bool" "void") (:* whitespace)(:+ (union (char-range #\a #\z) (char-range #\A #\Z)(char-range #\0 #\9) #\_ #\-))
              (:* whitespace) "(" (:* whitespace)(:? (:: (:or "int" "float" "string" "char" "bool")(:+ whitespace)
                      (:+ (union (char-range #\a #\z)(char-range #\A #\Z)(char-range #\0 #\9)#\_ #\-))(:* whitespace)
                      (:* (:: "," (:* whitespace) (:or "int" "float" "string" "char" "bool")(:+ whitespace)
                          (:+ (union (char-range #\a #\z)(char-range #\A #\Z)(char-range #\0 #\9)#\_ #\-))(:* whitespace)))))")" (:* whitespace) ";") )))
    (:* whitespace) "}" (:* whitespace) ";")
 (cons `(CLASS ,lexeme) (calc-lexer input-port))]

   ; 24. Identifier.
   [(:: (union (char-range #\a #\z) (char-range #\A #\Z)) (:* (union (char-range #\a #\z)(char-range #\A #\Z)(char-range #\0 #\9) #\_ #\-)))
    (cons `(IDENTIFIER ,lexeme) (calc-lexer input-port))]
   
   ; 22. Variable list.
   [(:: (char-range #\a #\z)(:+ (union (char-range #\a #\z)(char-range #\A #\Z)(char-range #\0 #\9) #\_ #\-)
             (:? (:: "[" (:+ (char-range #\0 #\9)) "]")))
             (:? (:: "," (:* whitespace) (char-range #\a #\z)(:+ (union (char-range #\a #\z)(char-range #\A #\Z)(char-range #\0 #\9) #\_ #\-)
             (:? (:: "[" (:+ (char-range #\0 #\9)) "]"))))))
    (cons `(VARIABLE-LIST ,lexeme) (calc-lexer input-port))]

  
   

))

(define lex-categories
  '(
    ("DIRECTIVE" DIRECTIVE)
    ("DIRECTIVE" GATO DIRECTIVE)
    ("DIRECTIVE" GATO DIRECTIVE IDENTIFIER)
    ("INCLUDE-SYSTEM" GATO SYSTEM-INCLUDE SYSTEM-IOSTREAM)
    ("INCLUDE-SYSTEM" GATO SYSTEM-INCLUDE SYSTEM-STRING)
    ("INCLUDE-LOCAL" GATO SYSTEM-INCLUDE COMILLAS IDENTIFIER DOT ACHE COMILLAS)
    ("USING-NAMESPACE" SYSTEM-NAMESPACE)
    ("CONST-DEF" GATO DIRECTIVE IDENTIFIER INT)
    ("CONST-DEF" GATO DIRECTIVE IDENTIFIER INT DOT INT)
    ("CONST-DEF" GATO DIRECTIVE IDENTIFIER IDENTIFIER)
    ("CLASS-HEADER" IDENTIFIER DOT ACHE)
    ("CLASS-HEADER" IDENTIFIER DOT CPP)
    ("CLASS_DECLARATION" CLASS IDENTIFIER LBRACE)
    ("CLASS_BODY" ACCESS-SPECIFIER CONSTRUCTOR-DECLARATION DESTRUCTOR-DECLARATION VARIABLE-DECLARATION METHOD-DECLARATION GETTER-DECLARATION SETTER-DECLARATION)
    ("ACCESS-SPECIFIER" ACCESS-TYPE COLON)
    ("CONSTRUCTOR-DECLARATION" IDENTIFIER PARAM SEMI)
    ("DESTRUCTOR-DECLARATION" TILDE IDENTIFIER PARAM SEMI)
    ("VARIABLE-DECLARATION" V-TYPE VARIABLE-LIST SEMI)
    ("VARIABLE-DECLARATION" V-TYPE IDENTIFIER SEMI)
    ("METHOD-DECLARATION" V-TYPE IDENTIFIER PARAM SEMI)
    ("GETTER-DECLARATION" V-TYPE getIDENTIFIER PARAM SEMI)
    ("SETTER-DECLARATION" V-TYPE setIDENTIFIER PARAM SEMI)
    ("CONSTRUCTOR-ASSIGNATION" ACCESS-TYPE IDENTIFIER COLON COLON IDENTIFIER PARAM LBRACE IDENTIFIER MATH-OP IDENTIFIER SEMI RBRACE)
    ("DESTRUCTOR-ASSIGNATION" ACCESS-TYPE IDENTIFIER COLON COLON TILDE IDENTIFIER PARAM LBRACE RBRACE)
    ("GETTER-ASSIGNATION" ACCESS-TYPE V-TYPE IDENTIFIER COLON COLON IDENTIFIER PARAM LBRACE RETURN IDENTIFIER SEMI RBRACE)
    ("SETTER-ASSIGNATION" ACCESS-TYPE V-TYPE IDENTIFIER COLON COLON IDENTIFIER PARAM LBRACE IDENTIFIER MATH-OP IDENTIFIER SEMI RBRACE)
    ("METHOD-ASSIGNATION" ACCESS-TYPE V-TYPE IDENTIFIER COLON COLON IDENTIFIER PARAM LBRACE)
    ("CONSTRUCTOR-ASSIGNATION" IDENTIFIER COLON COLON IDENTIFIER PARAM LBRACE IDENTIFIER MATH-OP IDENTIFIER SEMI RBRACE)
    ("CONSTRUCTOR-ASSIGNATION" IDENTIFIER COLON COLON IDENTIFIER PARAM LBRACE IDENTIFIER MATH-OP COMILLAS IDENTIFIER COMILLAS SEMI RBRACE)
    ("CONSTRUCTOR-ASSIGNATION" IDENTIFIER COLON COLON IDENTIFIER PARAM LBRACE THIS IDENTIFIER MATH-OP IDENTIFIER SEMI RBRACE)
    ("DESTRUCTOR-ASSIGNATION" IDENTIFIER COLON COLON TILDE IDENTIFIER PARAM LBRACE RBRACE)
    ("GETTER-ASSIGNATION" V-TYPE IDENTIFIER COLON COLON IDENTIFIER PARAM LBRACE RETURN IDENTIFIER SEMI RBRACE)
    ("GETTER-ASSIGNATION" V-TYPE IDENTIFIER COLON COLON IDENTIFIER PARAM LBRACE RETURN IDENTIFIER REL-OP INT SEMI RBRACE)
    ("SETTER-ASSIGNATION" V-TYPE IDENTIFIER COLON COLON IDENTIFIER PARAM LBRACE IDENTIFIER MATH-OP IDENTIFIER SEMI RBRACE)
    ("SETTER-ASSIGNATION" V-TYPE IDENTIFIER COLON COLON IDENTIFIER PARAM LBRACE THIS IDENTIFIER MATH-OP IDENTIFIER SEMI RBRACE)
    ("METHOD-ASSIGNATION" V-TYPE IDENTIFIER COLON COLON IDENTIFIER PARAM LBRACE)
    ("VARIABLE-ASSIGNATION" IDENTIFIER MATH-OP IDENTIFIER SEMI)
    ("VARIABLE-ASSIGNATION" IDENTIFIER MATH-OP IDENTIFIER MATH-OP INT SEMI)
    ("VARIABLE-BOTH" V-TYPE IDENTIFIER MATH-OP IDENTIFIER MATH-OP IDENTIFIER SEMI)
    ("VARIABLE-BOTH" V-TYPE IDENTIFIER MATH-OP IDENTIFIER LOG-OP IDENTIFIER SEMI)
    ("VARIABLE-BOTH" V-TYPE IDENTIFIER MATH-OP IDENTIFIER LPAR INT COMA INT RPAR SEMI)
    ("VARIABLE-BOTH" V-TYPE IDENTIFIER MATH-OP INT SEMI)
    ("POINTING" THIS MATH-OP REL-OP IDENTIFIER MATH-OP IDENTIFIER SEMI)
    ("FUNCTION-CALL" IDENTIFIER LPAR VARIABLE-LIST RPAR SEMI)
    ("FUNCTION-CALL" IDENTIFIER LPAR IDENTIFIER RPAR SEMI)
    ("FUNCTION-CALL" IDENTIFIER LPAR COMILLAS IDENTIFIER COMILLAS RPAR SEMI)
    ("FUNCTION-TO-VARIABLE" IDENTIFIER MATH-OP IDENTIFIER LPAR VARIABLE-LIST RPAR SEMI)
    ("FUNCTION-TO-VARIABLE" IDENTIFIER MATH-OP IDENTIFIER LPAR IDENTIFIER RPAR SEMI)
    ("FUNCTION-TO-VARIABLE" V-TYPE IDENTIFIER MATH-OP IDENTIFIER LPAR VARIABLE-LIST RPAR SEMI)
    ("FUNCTION-SYSTEM-CIN" SYSTEM-CIN REL-OP REL-OP IDENTIFIER SEMI )
    ("FUNCTION-SYSTEM-COUT" SYSTEM-COUT REL-OP REL-OP IDENTIFIER REL-OP REL-OP SYSTEM-ENDL SEMI )
    ("FUNCTION-SYSTEM-COUT" SYSTEM-COUT REL-OP REL-OP COMILLAS IDENTIFIER COMILLAS REL-OP REL-OP SYSTEM-ENDL SEMI )
    ("FUNCTION-SYSTEM-COUT" SYSTEM-COUT REL-OP REL-OP COMILLAS IDENTIFIER COMILLAS REL-OP REL-OP IDENTIFIER DOT IDENTIFIER PARAM REL-OP REL-OP SYSTEM-ENDL SEMI )
    ("FUNCTION-SYSTEM-COUT" SYSTEM-COUT REL-OP REL-OP COMILLAS IDENTIFIER COMILLAS REL-OP REL-OP IDENTIFIER REL-OP REL-OP SYSTEM-ENDL SEMI )
    ("FUNCTION-SYSTEM-COUT" SYSTEM-COUT REL-OP REL-OP IDENTIFIER REL-OP REL-OP COMILLAS IDENTIFIER COMILLAS REL-OP REL-OP IDENTIFIER REL-OP REL-OP SYSTEM-ENDL SEMI )
    ("OBJECT-DECLARATION" IDENTIFIER MATH-OP VARIABLE-LIST SEMI)
    ("OBJECT-DECLARATION" IDENTIFIER VARIABLE-LIST SEMI)
    ("OBJECT-DECLARATION" IDENTIFIER IDENTIFIER SEMI)
    ("OBJECT-DECLARATION" IDENTIFIER IDENTIFIER LPAR INT RPAR SEMI)
    ("OBJECT-DECLARATION" IDENTIFIER IDENTIFIER LPAR COMILLAS IDENTIFIER COMILLAS RPAR SEMI)
    ("OBJECT-ASSIGNATION" IDENTIFIER MATH-OP NEW IDENTIFIER LPAR VARIABLE-LIST RPAR SEMI)
    ("OBJECT-METHOD" IDENTIFIER DOT IDENTIFIER LPAR INT RPAR SEMI)
    ("OBJECT-METHOD" IDENTIFIER DOT IDENTIFIER LPAR COMILLAS IDENTIFIER COMILLAS RPAR SEMI)
    ("OBJECT-METHOD" IDENTIFIER DOT IDENTIFIER PARAM SEMI)
    ("F-DECLARATION" V-TYPE IDENTIFIER PARAM LBRACE)
    ("RETURNS" RETURN IDENTIFIER MATH-OP IDENTIFIER SEMI)
    ("RETURNS" RETURN BOOLEAN SEMI)
    ("MAIN-F" V-TYPE SYSTEM-MAIN PARAM LBRACE)
    ("MAIN-END" RETURN INT SEMI)
    ("IF" IF LPAR IDENTIFIER RPAR LBRACE)
    ("IF" IF LPAR IDENTIFIER PARAM RPAR LBRACE)
    ("IF" IF LPAR IDENTIFIER LOG-OP IDENTIFIER RPAR LBRACE)
    ("IF" IF LPAR IDENTIFIER REL-OP IDENTIFIER RPAR LBRACE)
    ("ELSE" ELSE LBRACE)
    ("ELSE-IF" ELSE IF LPAR IDENTIFIER RPAR LBRACE)
    ("ELSE-IF" ELSE IF LPAR IDENTIFIER LOG-OP IDENTIFIER RPAR LBRACE)
    ("ELSE-IF" ELSE IF LPAR IDENTIFIER REL-OP IDENTIFIER RPAR LBRACE)
    ("SWITCH-ST" SWITCH LPAR IDENTIFIER RPAR LBRACE)
    ("CASES" CASE INT COLON)
    ("BREAKS" BREAK SEMI)
    ("DEFAULT-CASES" DEFAULT COLON)
    ("FORS" FOR LPAR V-TYPE IDENTIFIER MATH-OP INT SEMI IDENTIFIER REL-OP IDENTIFIER SEMI IDENTIFIER INCREM RPAR LBRACE)
    ("FORS" FOR LPAR V-TYPE IDENTIFIER MATH-OP INT SEMI IDENTIFIER REL-OP INT SEMI IDENTIFIER INCREM-OP RPAR LBRACE)
    ("WHILES" WHILE LPAR IDENTIFIER RPAR LBRACE)
    ("WHILES" WHILE LPAR IDENTIFIER REL-OP IDENTIFIER RPAR LBRACE)
    ("WHILES" WHILE LPAR IDENTIFIER REL-OP INT RPAR LBRACE)
    ("WHILES" WHILE LPAR IDENTIFIER LOG-OP IDENTIFIER RPAR LBRACE)
    ("INCREMENTO" IDENTIFIER INCREM-OP SEMI)
    ("DO-START" DO LBRACE)
    ("DO-END" RBRACE WHILE LPAR IDENTIFIER RPAR SEMI)
    ("DO-END" RBRACE WHILE LPAR BOOLEAN RPAR SEMI)
    ("DO-END" RBRACE WHILE LPAR IDENTIFIER REL-OP IDENTIFIER RPAR SEMI)
    ("DO-END" RBRACE WHILE LPAR IDENTIFIER LOG-OP IDENTIFIER RPAR SEMI)
    ("END" RBRACE SEMI)
    ("END" RBRACE)
    ("EMPTY" )
))

(define (token->symbol token)
  (cond
    [(pair? token)
     (match (car token)
       ['IDENTIFIER 'IDENTIFIER]
       ['CONSTANT 'CONSTANT]
       ['INT 'INT]
       ['FLOAT 'FLOAT]
       ['BOOLEAN 'BOOLEAN]
       [else (car token)])]
    [else token]))


(define (tokenize-lines filename)
  (define in (open-input-file filename))
  (define content (port->lines in))
  (close-input-port in)
  (map (lambda (line)
         (let ([port (open-input-string line)])
           (let loop ([ts (calc-lexer port)] [acc '()])
             (if (null? ts)
                 (reverse acc)
                 (loop (cdr ts) (cons (token->symbol (car ts)) acc))))))
       content))

(define (match-category? token-line lex-categories)
  (let ([pattern (cdr lex-categories)])
    (equal? token-line pattern)))

(define (verificar-lineas tokens-por-linea)
  (for/list ([line tokens-por-linea]
             [n (in-naturals 1)])
    (define matched?
      (ormap (lambda (cat)
               (match-category? line cat))
             lex-categories))
    (if matched?
        (format "Línea ~a: ✅ correcta: ~a" n line)
        (format "Línea ~a: ❌ incorrecta: ~a" n line))))

(define resultado (verificar-lineas (tokenize-lines "./file1.cpp")))

(define (medir-tiempo-lexer input-port)
  (define start (current-inexact-milliseconds))
  (define tokens (tokenize-lines "./file5.cpp"))
  (define end (current-inexact-milliseconds))
  (printf "Tiempo en ms: ~a\n" (- end start)))

;(call-with-input-file "file1.cpp"
  ;(lambda (in)
    ;(medir-tiempo-lexer in)))

(provide calc-lexer lex-categories verificar-lineas tokenize-lines medir-tiempo-lexer call-with-input-file)