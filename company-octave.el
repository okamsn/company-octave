;; company mode for octave

(require 'cl-lib)
(require 'company)

(defun company-octave-grab-prefix ()
  "Get the completion target, including '.' for completing struct members. Octave REPL has a function 'completion_matches' to give candidates."
  (if (or (looking-at "\\_>") (looking-back "[a-zA-z_0-9]+\\."))
      (buffer-substring-no-properties (point)
                        (save-excursion
                          (skip-chars-backward "a-zA-Z_.0-9")
                          (point)))
    (unless (and (char-after)
                 (eq (char-syntax (char-after)) ?w))
      "")))

(defun company-octave-get-candidates (prefix)
  "Use Octave REPL's 'completion_matches' function to get candidates. If candidate has a '.' (i.e., it's completing a structure member), get the member only."
  (inferior-octave-send-list-and-digest
   (list (concat "completion_matches ('" prefix "');\n")))
  ;; Split candidates if they have an '.', keeping the last resulting item, then combine the resulting lists
  (mapcan (lambda (x) (if (listp x) x nil))
          (cl-loop for candidate in inferior-octave-output-list
                   collect (last (split-string candidate "\\.")))))

(defun company-octave-backend (command &optional arg &rest ignored)
  "Define the backend for interacting with the OCtave REPL."
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'company-octave-backend))
    (prefix (if (eq major-mode 'octave-mode)
                (company-octave-grab-prefix)))
    (candidates (company-octave-get-candidates arg))
    ;; (annotation ())
    (init (inferior-octave))))

(defun company-octave-settings ()
  (add-to-list 'company-backends '(company-octave-backend company-dabbrev-code company-capf company-files))
  (setq-mode-local octave company-dabbrev-code-other-buffers 'code)
  ;; (setq-mode-local octave company-dabbrev-code-ignore-case t)
  )

(provide 'company-octave)

;;; company-octave.el ends here
