;;; company-octave.el --- A company backend for GNU Octave -*- lexical-binding: t; -*-

;; Version: 0.1
;; URL: https://github.com/okamsn/company-octave
;; Package-Requires: (cl-lib company)
;; Keywords: convenience, tools, octave, company, completion

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
;; It uses the Octave REPL to provide completion candidates,
;; and so only provides built-in/submitted variables and functions.
;; It is able to provide completion candidates for
;; structure field names. For example, it will suggest
;; 'someStruct.someField' for 'someStruct.' (the REPL requires
;; the period), so long as the REPL is aware of 'someStruct.someField'
;; (such as by submitting the relevant region to the inferior Octave
;; process).

;;; Change Log:

;; Initial versions.


;;; Code:

(require 'cl-lib)
(require 'company)
(require 'company-dabbrev)
(require 'octave)

(defun company-octave-grab-prefix ()
  "Get the completion target, including '.' for completing struct members."
  ;; (interactive)
  (if (or (looking-at "\\_>")
          (looking-back "\\_>\\." nil))
      (buffer-substring-no-properties (point)
                                      (save-excursion
                                        (skip-chars-backward "a-zA-Z_.0-9")
                                        (point)))
    (unless (and (char-after)
                 (eq (char-syntax (char-after)) ?w))
      "")))

(defun company-octave-get-candidates (prefix)
  "Use Octave REPL's `completion_matches` function to get candidates for PREFIX."
  ;; (interactive)
  (with-local-quit (inferior-octave-send-list-and-digest (list (concat "completion_matches ('" prefix "');\n")))
                   inferior-octave-output-list))

(defun company-octave-get-annotation (candidate)
  "Annotate whether the completion candidate CANDIDATE is a function or a variable by using Octave's `which` command. To avoid an error involving '.' and argument passing, it doesn't complete structure names."
  (with-local-quit (if (string-match-p ".*\\..*" candidate) ;; Don't attempt for structures.
                       nil
                     (inferior-octave-send-list-and-digest (list (concat "which ('" candidate "');\n")))
                     (concat " "
                             (nth 3
                                  (split-string (car inferior-octave-output-list)
                                                " "))))))

;;; The Backend
;;;###autoload
(defun company-octave-backend (command &optional arg &rest ignored)
  "Define the backend for interacting with the Octave REPL. Actions taken are based on the argument COMMAND. ARG will be the prefix or completion candidate, depending on COMMAND. IGNORED is ignored."
  (interactive (list 'interactive))
  (with-local-quit (cl-case command
                     (interactive (company-begin-backend 'company-octave-backend))
                     (prefix (if (eq major-mode 'octave-mode)
                                 (company-octave-grab-prefix)))
                     (candidates (company-octave-get-candidates arg))
                     (annotation (company-octave-get-annotation arg))
                     (init (run-octave t))
                     )))

;;; Recommended settings
;;;###autoload
(defun company-octave-settings ()
  "Set up company with the appropriate backends. You might wish to change this. Add this function (or equivalent) to the hook for Octave mode."
  (add-to-list 'company-backends 'company-octave-backend)
  (setq company-dabbrev-code-other-buffers 'code)
  (setq-mode-local octave company-dabbrev-code-ignore-case t)
  )

(provide 'company-octave)

;;; company-octave.el ends here
