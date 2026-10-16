
;; Defined Parameters:

;; Contact Sets:
(sdegeo:define-contact-set "source" 4 (color:rgb 1 0 0 )"##" )
(sdegeo:define-contact-set "drain" 4 (color:rgb 0 1 0 )"##" )
(sdegeo:define-contact-set "gate" 4 (color:rgb 0 0 1 )"##" )
(sdegeo:define-contact-set "body" 4 (color:rgb 1 1 0 )"##" )

;; Work Planes:
(sde:workplanes-init-scm-binding)

;; Defined ACIS Refinements:
(sde:refinement-init-scm-binding)

;; Reference/Evaluation Windows:
(sdedr:define-refeval-window "RefEvalWin_source" "Line" (position 0 2 0) (position 0.35 2 0))
(sdedr:define-refeval-window "RefEvalWin_drain" "Line" (position 0.73 2 0) (position 1.08 2 0))
(sdedr:define-refeval-window "RefEvalWin_source_ext" "Line" (position 0.35 2 0) (position 0.45 2 0))
(sdedr:define-refeval-window "RefEvalWin_drain_ext" "Line" (position 0.63 2 0) (position 0.73 2 0))
(sdedr:define-refeval-window "RefEvalWin_global" "Rectangle" (position 0 0 0) (position 1.08 2.01 0))
(sdedr:define-refeval-window "RefEvalWin_channel" "Rectangle" (position 0.3 1.85 0) (position 0.78 2 0))
