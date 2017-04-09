(define (map p sequence)
  (accumulate (lambda (x y) (cons (p x) y))
              '() sequence))

(map (lambda (x) (* x x)) (list 1 2 3))
;; => (1 4 9)

(define (append seq1 seq2)
  (accumulate cons seq2 seq1))
(append (list 1 2) (list 4 5))
;; => (1 2 4 5)

(define (length sequence)
  (accumulate (lambda (x y) (+ y 1)) 0 sequence))
(length (list 2 3 4))
;; => 3

;;============================
(define (accumulate op initial sequence)
  (if (null? sequence)
      initial
      (op (car sequence)
          (accumulate op initial (cdr sequence)))))
