(define (make-unbound! var env)
  (define (match-proc vars vals cur-frame cur-env)
    (begin (set-cdr! vars (cdr vars))
           (set-cdr! vals (cdr vals))
           (env-loop match-proc end-frame end-env
                     (enclosing-environment cur-env) )))
  (define (end-env) 'done)
  (define (end-frame cur-frame cur-env)
    (env-loop match-proc end-frame end-env (enclosing-environment cur-env)))
  (env-loop match-proc end-frame end-env env))
