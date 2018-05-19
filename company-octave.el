;; company mode for octave

(require 'cl-lib)
(require 'company)


(defun company-octave-grab-prefix ()
  "Get the completion target, including '.' for completing struct members. Octave REPL has a function 'completion_matches' to give candidates."
   (if (or (looking-at "\\_>") (looking-back "\\_>\\."))
      (buffer-substring-no-properties (point)
                                      (save-excursion
                                        (skip-chars-backward "a-zA-Z_.0-9")
                                        (point)))
    (unless (and (char-after)
                 (eq (char-syntax (char-after)) ?w))
      "")))

(defun company-octave-get-candidates (prefix)
  "Use Octave REPL's 'completion_matches' function to get candidates."
  (inferior-octave-send-list-and-digest (list (concat "completion_matches ('" prefix "');\n")))
  inferior-octave-output-list)

(defun company-octave-get-annotation (prefix)
  "Use Octave REPL's 'which' command to get inline annotations. It tells us the type of the prefix."
  (inferior-octave-send-list-and-digest (list (concat "which ('" prefix "');\n")))
  (concat " " (nth 3 (split-string (car inferior-octave-output-list) " "))))

;; (defun company-octave-get-docbuffer (prefix)
;;   )


(defun company-octave-backend (command &optional arg &rest ignored)
  "Define the backend for interacting with the OCtave REPL."
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'company-octave-backend))
    (prefix (if (eq major-mode 'octave-mode)
                (company-octave-grab-prefix)))
    (candidates (company-octave-get-candidates arg))
    (annotation (company-octave-get-annotation arg))
    ;;(init (inferior-octave))
    ))



(defun company-octave-settings ()
  (add-to-list 'company-backends '(company-octave-backend company-dabbrev-code company-files))
  (setq-mode-local octave company-dabbrev-code-other-buffers 'code)
  ;; (setq-mode-local octave company-dabbrev-code-ignore-case t)
  )

(provide 'company-octave)

;;; company-octave.el ends here
