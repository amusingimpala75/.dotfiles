;;; word-count.el --  -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Luke Murray

;; Author: Luke Murray <69653100+amusingimpala75@users.noreply.github.com>
;; Keywords: terminal
;; Package-Version: 20260216
;; Package-Requires:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the MIT License.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

;;; Commentary:

;; This package adds a word count to the mode line

;;; Code:

(defun word-count-mode-count-words-dwim ()
  "Count word in buffer or region if active."
  (format "%d" (count-words
                (if (region-active-p) (min (mark) (point)) (point-min))
                (if (region-active-p) (max (mark) (point)) (point-max))
                nil)))

;;;###autoload
(define-minor-mode word-count-mode
  "Toggle word count.
When enabled, show the word count in the mode line."
  :init-value nil
  :lighter (" WC[" (:eval (word-count-mode-count-words-dwim)) "]"))

(provide 'word-count)
;;; word-count.el ends here
