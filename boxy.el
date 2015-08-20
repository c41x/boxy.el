;; box api (in progress)
(defun boxy:hide-overlay (ov)
  (when (overlay-get ov 'is-box)
    (overlay-put ov 'invisible nil)
    (overlay-put ov 'prv-before-string (overlay-get ov 'before-string))
    (overlay-put ov 'before-string "")))

(defun boxy:show-overlay (ov)
  (when (and (overlay-get ov 'is-box)
	     (overlay-get ov 'prv-before-string))
    (overlay-put ov 'invisible t)
    (overlay-put ov 'before-string (overlay-get ov 'prv-before-string))
    (overlay-put ov 'prv-before-string nil)))

(defun boxy:overlays-in-this-line ()
  (overlays-in (line-beginning-position) (line-end-position)))

(defun boxy:delete-if-box (ov)
  (when (overlay-get ov 'is-box)
    (delete-overlay ov)))

(defun boxy:line (line column width frame-type text)
  (save-excursion
    (goto-line line)
    ;; delete all boxes in this line
    (mapc 'boxy:delete-if-box (boxy:overlays-in-this-line))
    (let ((column-offset (+ (line-beginning-position) column))
	  (max-width (min (- (window-width) column) width))
	  (ov nil)
	  (left (point))
	  (right (point))
	  (boxes 0))
      (mapc 'boxy:hide-overlay (boxy:overlays-in-this-line))
      ;; find left position
      (while (and (<= (save-excursion (forward-char 1) (current-column)) column)
		  (<= (+ (point) 1) (line-end-position)))
	(forward-char 1))
      (setq boxes (current-column))
      (setq left (min (point) (min column-offset (line-end-position))))
      ;; find right position
      (while (and (<= (save-excursion (forward-char 1) (current-column)) (min (window-width) (+ column width)))
		  (<= (+ (point) 1) (line-end-position)))
	(forward-char 1))
      (setq right (min (point) (line-end-position)))
      ;; create overlay
      (setq ov (make-overlay left right))
      (overlay-put ov 'is-box t)
      (overlay-put ov 'invisible t)
      (overlay-put ov 'before-string
		   (concat (make-string (- column boxes) ?\ )
			   (cond ((equal frame-type 'top)
				  (concat (make-string 1 ?\╔)
					  (make-string (- max-width 2) ?\═)
					  (make-string 1 ?\╗)))
				 ((equal frame-type 'bottom)
				  (concat (make-string 1 ?\╚)
					  (make-string (- max-width 2) ?\═)
					  (make-string 1 ?\╝)))
				 (t (concat (make-string 1 ?\║)
					    (substring text 0 (min (- max-width 2) (length text)))
					    (make-string (max 0 (- max-width 2 (length text))) ?\ )
					    (make-string 1 ?\║))))))
      (mapc 'boxy:show-overlay (boxy:overlays-in-this-line))
      ;; return overlay
      ov)))

(defun boxy ()
  (boxy:line 41 20 22 'top "")
  (boxy:line 42 20 22 nil "")
  (boxy:line 43 20 22 nil "  asdf")
  (boxy:line 44 20 22 nil "")
  (boxy:line 45 20 22 nil "")
  (boxy:line 46 20 22 nil "")
  (boxy:line 47 20 22 nil "")
  (boxy:line 48 20 22 'bottom ""))

(boxy)
(remove-overlays)
