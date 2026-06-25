;;; imacs-org.el --- Org-mode configuration -*- lexical-binding: t -*-

;; Author: amusingimpala75
;; Maintainer: amusingimpala75
;; Version: 0.1.0
;; Package-Requires:
;; Homepage:
;; Keywords:

;;; Commentary:

;;; Code:
(use-package org
  :defer 1
  :hook
  ;; Fix for electric pair [TODO] remove electric pair from org-mode?
  (org-mode . (lambda ()
                (setq-local electric-pair-inhibit-predicate
                            (lambda (c)
                              (if (char-equal c ?\<) ;; > just to silence this
                                  t
                                (electric-pair-default-inhibit c))))))
  :custom
  ;; Apply font-lock to source code blocks
  (org-src-fontify-natively t)
  ;; Make export look exactly like source
  (org-src-preserve-indentation t)
  ;; Enable org indent by default
  (org-startup-indented t)
  ;; Hide leading *
  (org-hide-emphasis-markers t)
  ;; setup org modules for tempo
  ;; (I'm not using any of the ol modules currently, could change)
  (org-modules '(org-tempo ox-typst ox-pandoc))
  :functions
  org-beginning-of-line
  org-end-of-line
  org-export-define-derived-backend
  org-export-output-file-name
  org-export-to-file
  org-mark-element
  :config
  (custom-set-faces
   ;; Make certain faces fixed-pitch
   '(org-block ((t (:inherit fixed-pitch))))
   '(org-table ((t (:inherit fixed-pitch))))
   '(org-code ((t (:inherit (shadow fixed-pitch)))))
   '(org-verbatim ((t (:inherit fixed-pitch))))
   ;; Different font sizes for headings
   '(org-level-1 ((t (:weight bold :height 1.5))))
   '(org-level-2 ((t (:weight bold :height 1.4))))
   '(org-level-3 ((t (:weight bold :height 1.3))))
   '(org-level-4 ((t (:weight bold :height 1.2))))
   '(org-level-5 ((t (:weight bold :height 1.1))))
   '(org-level-6 ((t (:weight bold))))
   '(org-level-7 ((t (:weight bold))))
   '(org-level-8 ((t (:weight bold)))))
  ;; Load various babel langauges [TODO] clean this code
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (shell . t))))

;; Nicer looking org mode
(use-package org-modern
  :ensure t
  :defer t
  :custom
  ;; Replace with custom stars, see below
  (org-modern-star 'replace)
  ;; Configure stars (one glyph missing in default with Maple Mono NF CN)
  (org-modern-replace-stars "◉○◈◇✿") ; replace the last glyph
  :hook org-mode)

;; Org modern indent
(use-package org-modern-indent
  :ensure t
  :defer t
  :hook org-modern-mode)

;; Export with pandoc for eg docx
(use-package ox-pandoc
  :ensure t
  :defer t)

;; Colorize text blocks on export
(use-package engrave-faces
  :ensure t
  :defer t)

;; Showing markup delimiters on hover
(use-package org-appear
  :ensure t
  :defer t
  :hook org-mode
  :custom (org-appear-autolinks t))

;; Presentation method
(use-package org-present
  :ensure t
  :defer t)

;; Export org mode things with typst
(use-package ox-typst
  :ensure t
  :defer t
  :custom
  ;; Typst should be set up per-project
  (org-typst-process "nix develop -c typst c \"%s\""))

(provide 'imacs-org)
;;; imacs-org.el ends here
