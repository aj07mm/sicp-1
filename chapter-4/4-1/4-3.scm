(define (eval exp env)
  (let ((eval-proc (get (type-tag exp) 'eval)))
    (if eval-proc
        (eval-proc (type-content exp) env)
        (error "Unkown expression type: EVAL" exp))))

;; data as a pair
(define (type-tag data)
  (car data))
(define (type-content data)
  (cdr data))
(define (attach-tag tag x)
  (cons tag x))

(define (dispatch-table)
  (let ((table (cons 'table '())))

    (define (add old new)
      (set-cdr! old (cons new (cdr old))))

    (define (assoc cell tab)
      (define (assoc-list x list)
        (cond ((null? list) false)
              ((eq? x (car (car list))) (car list))
              (else (assoc-list x (cdr list)))))
        (assoc-list cell (cdr tab)))

    (define (put tag1 tag2 proc)
      (cond ((null? (cdr table))
             (add table (cons tag1 '()))
             (add (assoc tag1 table) (cons tag2 proc)))
            (else (let ((potential-tag1 (assoc tag1 table)))
                    (if potential-tag1
                        (let ((potential-tag2 (assoc tag2 potential-tag1)))
                          (if potential-tag
                              (set-cdr! potential-tag2 proc)
                              (add potential-tag1 (cons tag2 proc))))
                        (begin (add table tag1)
                               (add (assoc tag1 table) (cons tag2 proc))))))))

    (define (get tag1 tag)
      (cond ((null? (cdr table)) false)
            (else (let ((potential-tag1 (assoc tag1 table)))
                    (if potential-tag1
                        (let ((potential-tag2 (assoc tag2 potential-tag1)))
                          (if potential-tag
                              (cdr potential-tag)
                              false))
                        false)))))

    (define (dispatch me)
      (cond ((eq? me 'put) put)
            ((eq? me 'get) get)
            (else (error "Unkown expression arg: dispatch"))))
    dispatch))

(define dispatch (dispatch-table))
(define (get t1 t2)
  ((dispatch 'get) t1 t2))
(define (put t1 t2 proc)
  ((dispatch 'put) t1 t2 proc))

;; data-installation
(define (number-package-install)
  (define (eval-self number env)
    number)
  ;; external
  (define (tag x) (attach-tag 'number x))
  (put 'number 'eval eval-self)
  (put 'number 'make tag))

(define (string-package-install)
  (define (eval-self string env)
    string)
  (define (tag x) (attach-tag 'g x))
  (put 'string 'eval eval-self)
  (put 'string 'make tag))

(define (quote-package-install)
  (define (eval-self quote env)
    quote)
  (define (tag x) (attach-tag 'quote x))
  (put 'quote 'eval eval-self)
  (put 'quote 'make tag))

(define (assignment-packakge-install)
  (define (make-assignment variable value)
    (list variable value))
  (define (assignment-variable assign)
    (car assign))
  (define (assignment-value assign)
    (cadr assign))
  (define (eval-self exp env)
    (set-variable-value! (assignment-variable exp)
                         (eval (assignment-value exp) env)
                         env)
    'ok)
  (define (tag x) (attach-tag 'set! x))
  (put 'set! 'make (lambda (x y) (tag (make-assignment x y))))
  (put 'set! 'eval eval-self))

(define (definition-package-install)
  (define (make-definition variable value)
    (list variable value))
  (define (definition-variable def)
    (if (symbol? (car def))
        (car def)
        (caar def)))
  (define (definition-value def)
    (if (symbol? (car def))
        (cadr def)
        (make-lambda (cdar def)
                     (cdr def))))
  (define (eval-self def env)
    (define-variable! (define-variable! def)
      (eval (definition-value def) env)
      env)
    'ok)
  (define (tag x) (attach-tag 'definition x))
  (put 'definition 'make (lambda (x y) (tag (make-definition x y))))
  (put 'definition 'eval eval-self))


(define (lambda-package-install)
  (define (make-lambda para body)
    (cons para body))
  (define (lambda-parameters l)
    (car l))
  (define (lambda-body l)
    (cdr l))
  (define (eval-self lambda env)
    (make-procedure (lambda-parameters lambda) (lambda-body lambda) env))

  (define (tag x) (attach-tag 'lambda x))
  (put 'lambda 'make (lambda (x y) (tag (make-lambda x y))))
  (put 'lambda 'eval eval-self))

(define (begin-package-install)
  (define (first-exp exps)
    (car exps))
  (define (rest-exp exps)
    (cdr exps))
  (define (last-exp? exps)
    (null? (rest-exp exps)))
  (define (eval-self exps env)
    (cond ((last-exp? exps)
           (eval (first-exp exps) env))
          (else (eval (first-exp exps) env)
                (eval-self (rest-exp exps) env))))
  (define (tag x) (attach-tag 'begin x))
  (put 'begin 'eval eval-self)
  (put 'begin 'make tag))

(define (if-package-install)
  (define (make-if pre con alt)
    (list pre con alt))
  (define (if-predicate exp)
    (car exp))
  (define (if-consequent exp)
    (cadr exp))
  (define (if-alternative exp)
    (caddr exp))
  (define (eval-self exp env)
    (if (true? (eval (if-predicate exp) env))
        (eval (if-consequent exp) env)
        (eval (if-alternative exp) env)))
  (define (tag x) (attach-tag 'if x))
  (put 'if 'eval eval-self)
  (put 'if 'make (lambda (x y z) (tag (make-if x y z)))))

(define (cond-package-install)
  (define (cond-predicate clause)
    (car clause))
  (define (cond-actions clause)
    (cdr clause))
  (define (cond-else-clause? clause)
    (eq? (cons-predicate clause) 'else))
  (define (cond->if clauses) (expand-clauses clauses))
  (define (expand-clauses clauses)
    (if (null? clauses)
        'false
        (let ((first (car clauses))
              (rest (cdr clauses)))
          (if (cond-else-clause? first)
              (if (null? rest)
                  (sequence->exp (cons-actions first))
                  (error "ELSE clause isn't last: COND->IF" clauses))
              (make-if (cond-predicate first)
                       (sequence->exp (cond-actions first))
                       (expand-clauses rest))))))
  (define (eval-self exp env)
    (eval (cons->if exp) env))
  (define (tag x) (attach-tag 'cond x))
  (put 'cond 'eval eval-self))

(define (application-package-install)
  (define (make-call x y)
    (cons x y))
  (define (operator exp) (car exp))
  (define (operands exp) (cdr exp))
  (define (no-operands? ops) (null? ops))
  (define (first-operand ops) (car ops))
  (define (rest-operands ops) (cdr ops))
  (define (eval-self exp env)
    (apply (eval (operator exp) env)
           (list-of-values (operands exp) env)))
  (define (tag x) (attach-tag 'call x))
  (put 'call 'eval eval-self)
  (put 'call 'make (lambda (x y) (tag (make-call x y)))))

;;====================
;; other functions
(define (sequence->exp seq)
  (cond ((null? seq) seq)
        ((null? (cdr seq)) (car seq))
        (else (make-begin seq))))

(define (apply procedure arguments)
  (cond ((primitive-procedure? procedure)
         (apply-primitive-procedure procedure arguments))
        ((compound-procedure? procedure)
         (eval-sequence
          (procedure-body procedure)
          (extend-environment (procedure-parameters procedure)
                              arguments
                              (procedure-environment procedure))))
        (else (error "Unknown procedure type -- APPLY" procedure))))
