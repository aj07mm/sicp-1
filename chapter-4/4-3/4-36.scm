(define (a-pythagorean-triple-from low)
  (let ((k (an-integer-starting-from low)))
    (let ((j (an-integer-between low k)))
      (let ((i (an-integer-between low j)))
        (require (= (+ (* i i) (* j j)) (* k k)))
        (list i j k)))))
