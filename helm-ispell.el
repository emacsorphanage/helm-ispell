;;; helm-ispell.el --- ispell-complete-word with helm interface

;; Copyright (C) 2013 by Syohei YOSHIDA

;; Author: Syohei YOSHIDA <syohex@gmail.com>
;; URL:
;; Version: 0.01

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

;;; Code:

(require 'helm)
(require 'ispell)
(require 'thingatpt)

(defgroup helm-ispell nil
  "Insert word by ispell"
  :group 'helm)

(defun helm-ispell--case-function (input)
  (let ((case-fold-search nil))
    (cond ((string-match-p "\\`[A-Z]\\{2\\}" input) 'upcase)
          ((string-match-p "\\`[A-Z]\\{1\\}" input) 'capitalize)
          (t 'identity))))

(defun helm-ispell--compare-length (a b)
  (< (length a) (length b)))

(defun helm-ispell--init ()
  (with-helm-current-buffer
    (let ((word (thing-at-point 'word)))
      (let ((input (downcase word))
            (case-func (helm-ispell--case-function word)))
        (when (string-match-p "\\`[a-z]+\\'" input)
          (mapcar case-func
                  (sort (lookup-words (concat input "*") ispell-complete-word-dict)
                        'helm-ispell--compare-length)))))))

(defun helm-ispell--action-insert (candidate)
  (let ((curpoint (point)))
    (backward-word 1)
    (delete-region (point) curpoint)
    (insert candidate)))

(defvar helm-ispell--source
  '((name . "Ispell")
    (candidates . helm-ispell--init)
    (action . helm-ispell--action-insert)
    (candidate-number-limit . 9999)))

;;;###autoload
(defun helm-ispell ()
  (interactive)
  (helm :sources '(helm-ispell--source) :input (thing-at-point 'word)))

(provide 'helm-ispell)

;;; helm-ispell.el ends here
