(define (multiple-dwelling)
  (define (conditions? a-list)
    (let ((baker (list-ref a-list 0))
          (cooper (list-ref a-list 1))
          (fletcher (list-ref a-list 2))
          (miller (list-ref a-list 3))
          (smith (list-ref a-list 4)))
      (and (not (= baker 5))
           (not (= fletcher 1))
           (not (= cooper 1))
           (not (= fletcher 5))
           (> miller cooper)
           (not (= (abs (- smith fletcher)) 1))
           (not (= (abs (- fletcher cooper)) 1)))))
  (let ((all-combinations (distinct-permutations '(1 2 3 4 5))))
    (car (filter conditions? all-combinations) )))

(define (distinct-permutations items)
  (define (iter left result)
    (if (null? left)
        result
        (iter (cdr left)
              (flat-map (lambda (x)
                          (map (lambda (y) (cons y x))
                               (filter (lambda (z) (boolean? (memq z x))) items)))
                        result))))
  (iter items '(())))

(define (flat-map f list)
  (fold (lambda (x y) (append x y)) '()
        (map f list)))