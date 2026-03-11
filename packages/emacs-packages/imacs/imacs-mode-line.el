;;; imacs-mode-line.el --- Mode line config for Impala's Emacs -*- lexical-binding: t; -*-

;; Author: AmusingImpala75
;; Maintainer: AmusingImpala75
;; Version: 0.1
;; Package-Requires:
;; Homepage:
;; Keywords:

;; This file is not part of GNU Emacs

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;; Code:

;; Basic mode line as emacs, just with a lambda
;; out left, padding up and down, and right
;; alignment for the right half

(use-package emacs
  :custom
  (mode-line-format
   '("%e"
     (:propertize " " display (raise +0.2))
     (:propertize " " display (raise -0.2))
     "λ "
     mode-line-client
     mode-line-modified
     mode-line-remote
     " "
     mode-line-frame-identification
     mode-line-buffer-identification
     " "
     mode-line-position
     " "
     mode-line-format-right-align
     (project-mode-line project-mode-line-format)
     (vc-mode vc-mode)
     " "
     mode-line-modes
     mode-line-misc-info
     " "))
  (mode-line-modes-delimiters '("" . ""))
  ;; Hide most of the minor modes (the ones that don't
  ;; provide info besides that it's enabled)
  (mode-line-collapse-minor-modes
   '( eldoc-mode hs-minor-mode which-key-mode completion-preview-mode
      buffer-face-mode org-indent-mode visual-line-mode
      treesit-fold-mode yas-minor-mode subword-mode)))

;; Just show the bare styled numbers, no
;; brackets or 'Flymake'
(use-package flymake
  :custom
  (flymake-mode-line-title "")
  (flymake-mode-line-counter-format
   '("" flymake-mode-line-error-counter
     flymake-mode-line-warning-counter
     flymake-mode-line-note-counter)))

;; Similar as with flymake, remove the 'envrc[' and ']'
(use-package envrc
  :custom
  (envrc-on-lighter '(" " (:propertize "on" face envrc-mode-line-on-face)))
  (envrc-none-lighter '(" " (:propertize "none" face envrc-mode-line-none-face)))
  (envrc-error-lighter '(" " (:propertize "error" face envrc-mode-line-error-face))))

;; Show the project in the modeline, formatting just the name
(use-package project
  :custom
  (project-mode-line t)
  (project-mode-line-format
   '(:eval
     (if (project-current)
         (project-mode-line-format)))))

;; Show the current time in the mode line
(use-package time
  :hook (after-init . display-time-mode)
  :custom
  (display-time-default-load-average nil)
  (display-time-world-time-format "%A %d"))

(provide 'imacs-mode-line)

;;; imacs-mode-line.el ends here
