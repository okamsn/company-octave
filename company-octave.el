;;; company-octave.el --- A company backend for GNU Octave

;; Version: 0.1
;; Package-Requires: (cl-lib company)
;; Keywords: octave, company, backend

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.



;;; Commentary:

;; This package provides a company backend for GNU Octave.
;; It is able to provide completion candidates for
;; structure field names, and uses the Octave inferior
;; process to provide completions. Therefore, the Octave
;; REPL must be running (use the command "run-octave").

;;; Change Log:

;; Initial versions.


;;; Code:

(require 'cl-lib)
(require 'company)


(defun company-octave-grab-prefix ()
  "Get the completion target, including '.' for completing struct members."
  ;; (interactive)
  (if (or (looking-at "\\_>") (looking-back "\\_>\\." nil))
      (buffer-substring-no-properties (point)
                                      (save-excursion
                                        (skip-chars-backward "a-zA-Z_.0-9")
                                        (point)))
    (unless (and (char-after)
                 (eq (char-syntax (char-after)) ?w))
      "")))

(defun company-octave-get-candidates (prefix)
  "Use Octave REPL's 'completion_matches' function to get candidates for PREFIX."
  ;; (interactive)
  (with-local-quit
  (inferior-octave-send-list-and-digest (list (concat "completion_matches ('" prefix "');\n")))
  inferior-octave-output-list))

(defun company-octave-get-annotation (prefix)
  "Use Octave REPL's 'which' command to get inline annotations. It tells us the type of PREFIX. There's an error with completing structure names, so it just doesn't."
  (with-local-quit
    (if (string-match-p ".*\\..*" prefix) ;; Don't attempt for structures.
        nil
      (inferior-octave-send-list-and-digest (list (concat "which ('" prefix "');\n")))
      (concat " " (nth 3 (split-string (car inferior-octave-output-list) " ")))
      )))

;; How does this differ from annotate?
;; (defun company-octave-get-meta-info (prefix)
;;   "Use Octave REPL's 'which' command to get inline annotations. It tells us the type of the prefix."
;;   (with-local-quit
;;   (inferior-octave-send-list-and-digest (list (concat "which ('" prefix "');\n")))
;;   (car inferior-octave-output-list)))

;; (defun company-octave-get-doc-buffer (prefix)
;;   ;; get basic info on prefix
;;   (inferior-octave-send-list-and-digest (list (concat "which ('" arg "');\n")))
;;   (pcase (nth 3 (split-string (car inferior-octave-output-list) " "))
;;     ("function" (progn
;;                   (inferior-octave-send-list-and-digest (list (concat "help ('" arg "');\n")))))
;;     ("variable" (progn
;;                   (inferior-octave-send-list-and-digest (list (concat "type ('" arg "', '-q');\n"))))))
;;   ;; remove empty lines, separate what's left
;;   (company-doc-buffer
;;    (combine-and-quote-strings (cl-loop for candidate in inferior-octave-output-list
;;                                        if (not (string-equal candidate ""))
;;                                        collect candidate)
;;                               "\n"))
;;   (company-show-doc-buffer))

;;;###autoload
(defun company-octave-backend (command &optional arg &rest ignored)
  "Define the backend for interacting with the Octave REPL."
  (interactive (list 'interactive))
  (with-local-quit
  (cl-case command
    (interactive (company-begin-backend 'company-octave-backend))
    (prefix (if (eq major-mode 'octave-mode)
                (company-octave-grab-prefix)))
    (candidates (company-octave-get-candidates arg))
    (annotation (company-octave-get-annotation arg))
    (init (run-octave))
    ;; (doc-buffer (company-octave-get-doc-buffer arg)))
    )))

;;;###autoload
(defun company-octave-settings ()
  "Set up company with the appropriate backends. You might wish to change this."
  (add-to-list 'company-backends 'company-octave-backend)
  (setq company-dabbrev-code-other-buffers 'code)
  ;; (setq-mode-local octave company-dabbrev-code-ignore-case t)
  )

(provide 'company-octave)

;;; company-octave.el ends here
