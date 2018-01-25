;;; my-interactive-stuff.el --- Bunch of interactive functions from my old elisp/.emacs setup.  -*- lexical-binding: t; -*-

;; Copyright (C) 2018  

;; Author:  <jason@Necronomicon>
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; 

;;; Code:

(require 'my-utilities
         (concat
          (file-name-as-directory (file-name-directory load-file-name) )
          (file-name-as-directory "..")
          (file-name-as-directory "my-utilities")
          "my-utilities.el"))

(defun my-interactive-stuff/indent-buffer ()
  "Indent the current buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))

(defun my-interactive-stuff/shell-command-on-buffer (cmd)
  "Run the command `cmd' on the current buffer."
  (interactive "scommand: ")
  (save-excursion
    (shell-command-on-region (beginning-of-buffer) (end-of-buffer) cmd)))

(defun my-interactive-stuff/generate-line-comment (width text &optional char)
  (interactive "nWidth: \nsText: \nsPadding Char: ")
  (let* ((text-length 0) (left-length 0) (right-length 0)
         (comment-start (my-utilities/r-trim comment-start))
         (comment-end (if (string= comment-end "") comment-start
                        (my-utilities/r-trim comment-end))))
    (setq text-length (length text))
    (setq left-length (- (/ (- width text-length) 2) (length comment-start)))
    (setq right-length
          (+ (- (/ (- width text-length) 2) (length comment-end))
             (if (or
                  (and (= 1 (% text-length 2))
                       (= 0 (% width 2)))
                  (and (= 0 (% text-length 2))
                       (= 1 (% width 2))))
                 1 0)))
    (insert
     (concat
      comment-start
      (make-string left-length (string-to-char char))
      text
      (make-string right-length (string-to-char char))
      comment-end "\n"))))

(defun my-interactive-stuff/generate-block-comment (width text &optional char)
  (interactive "nWidth: \nsText: \nsPadding Char: ")
  (let ((dummy-text (concat char char)))
    (my-interactive-stuff/generate-line-comment width dummy-text char)
    (my-interactive-stuff/generate-line-comment width text char)
    (my-interactive-stuff/generate-line-comment width dummy-text char)))

(defun my-interactive-stuff/collapse-to-level (column)
  "Collapse all definitions in the current code buffer to the given
indentation level."
  (interactive "P")
  (set-selective-display (if selective-display nil (or column 1))))

(defun my-interactive-stuff/un-collapse ()
  "Un-Collapse all definitions in the current code buffer."
  (interactive)
  (set-selective-display nil))

;; improved from Steve Yegge's Emacs conf by Johan Anderson
(defun my-interactive-stuff/rename-file-and-buffer ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (message "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New name: " filename)))
        (cond ((get-buffer new-name)
               (message "A buffer named '%s' already exists!" new-name))
              (t
               (rename-file name new-name 1)
               (rename-buffer new-name)
               (set-visited-file-name new-name)
               (set-buffer-modified-p nil)))))))


;; stolen from Marlon Pierce's blog here: http://communitygrids.blogspot.com/2007/11/emacs-goto-column-function.html
;; who apparently stole it from this file here: http://www.icce.rug.nl/edu/1/cygwin/extra/dot.emacs
(defun my-interactive-stuff/goto-column (number)
  "Untabify, and go to a column number within the current line (1 is beginning of the line)."
  (interactive "nGoto column: ")
  (beginning-of-line)
  (untabify (point-min) (point-max))
  (while (> number 1)
    (if (eolp)
        (insert ? )
      (forward-char))
    (setq number (1- number))))

(defun my-interactive-stuff/eval-and-replace-last-sexp ()
  "Evaluate the sexp before POINT, and replace it with the returned value."
  (interactive)
  (backward-kill-sexp)
  (prin1 (eval (read (current-kill 0)))
         (current-buffer)))

(defun my-interactive-stuff/gather-last-keyboard-macro (name)
  "Name the last-entered keyboard macro, and dump it to the current buffer as a
function definition."
  (interactive "sName: ")
  (let ((symbol (make-symbol name)))
    (name-last-kbd-macro symbol)
    (insert-kbd-macro symbol)))

(defun my-interactive-stuff/revert-all-buffers ()
  "Refreshes all open buffers from their respective files."
  (interactive)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (and (buffer-file-name) (not (buffer-modified-p)))
        (revert-buffer t t t) )))
  (message "Refreshed open files."))

(defun my-interactive-stuff/upperscore-region ()
  "Converts Camel/Pascal case in the current region to uppercase underscore."
  (interactive)
  (save-excursion
    (replace-regexp "\\([a-zA-Z]\\)\\([A-Z]\\)" "\\1_\\2" nil (region-beginning) (region-end)))
  (upcase-region (region-beginning) (region-end)))

(defun my-interactive-stuff//change-number-at-point (fun)
  (skip-chars-backward "0-9")
  (or (looking-at "[0-9]+")
      (error "No number at point"))
  (replace-match (number-to-string (funcall fun (string-to-number (match-string 0))))))

(defun my-interactive-stuff/increment-number-at-point ()
  (interactive)
  (my-interactive-stuff//change-number-at-point '1+))

(defun my-interactive-stuff/decrement-number-at-point ()
  (interactive)
  (my-interactive-stuff//change-number-at-point '1-))

(provide 'my-interactive-stuff)
;;; my-interactive-stuff.el ends here
