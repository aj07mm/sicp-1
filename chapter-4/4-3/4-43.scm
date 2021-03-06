(define (yachet-puzzle-slow)
  (let ((moore (amb  'mary 'gabrielle 'lorna 'rosalind 'melissa))
        (downing (amb  'mary 'gabrielle 'lorna 'rosalind 'melissa))
        (hall (amb  'mary 'gabrielle 'lorna 'rosalind 'melissa))
        (barnacle (amb  'mary 'gabrielle 'lorna 'rosalind 'melissa))
        (parker (amb  'mary 'gabrielle 'lorna 'rosalind 'melissa)))
    (require (= moore 'mary))
    (require (not (= barnacle 'gabrielle) ))
    (require (not (= moore 'lorna) ))
    (require (not (= hall 'rosalind) ))
    (require (not (= downing 'melissa)))
    (require (= barnacle 'melissa))
    (require (not (= parker 'gabrielle)))
    (require (distinct? (list moore downing hall barnacle parker)))
    (list (list 'moore moore)
          (list 'downing downing)
          (list 'hall hall)
          (list 'barnacle barnacle)
          (list 'parker parker))))

(define (yachet-puzzle-fast)
  (let ((barnacle (amb  'mary 'gabrielle 'lorna 'rosalind 'melissa)))
    (require (not (= barnacle 'gabrielle) ))
    (require (= barnacle 'melissa))
    (let ((moore (amb  'mary 'gabrielle 'lorna 'rosalind 'melissa)))
      (require (not (= moore 'lorna) ))
      (require (= moore 'mary))
      (let ((downing (amb  'mary 'gabrielle 'lorna 'rosalind 'melissa)))
        (require (not (= downing 'melissa)))
        (let ((parker (amb  'mary 'gabrielle 'lorna 'rosalind 'melissa)) )
          (require (not (= parker 'gabrielle)))
          (let ((hall (amb  'mary 'gabrielle 'lorna 'rosalind 'melissa)) )
            (require (not (= hall 'rosalind) ))
            (require (distinct? (list moore downing hall barnacle parker)))
            (list (list 'moore moore)
                  (list 'downing downing)
                  (list 'hall hall)
                  (list 'barnacle barnacle)
                  (list 'parker parker))))))))
