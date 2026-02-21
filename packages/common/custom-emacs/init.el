;;; package --- Custom Emacs Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Bind key for :bind keyword
(require 'bind-key)
;; Nix-adjacent settings
(require 'nix-settings)

;; Custom application prefix map
(define-prefix-command 'my/applications nil "Applications")
(bind-key "C-x C-a" 'my/applications)

(defun my/user-secret-else (file else)
  "Get user secret from `FILE' or a default value `ELSE' if not installed."
  (if (file-exists-p file)
      (with-temp-buffer
        (insert-file-contents file)
        (read (current-buffer)))
    else))

;; Benchmarking, not in use currently (but so I remember it does exist)
;; (use-package benchmark-init
;;   :ensure t
;;   :demand t
;;   :hook (after-init . benchmark-init/deactivate)
;;   :init
;;   (benchmark-init/activate))

;; Disable the scroll bar
(use-package scroll-bar
  :custom (scroll-bar-mode nil)) ;;  Also see frame defaults

;; Disable tool bar
(use-package tool-bar
  :custom (tool-bar-mode nil))

(use-package emacs
  :custom
  ;; Disable menu bar, unless it's on macOS ('cause it doesn't take
  ;; up any extra screen space there)
  (menu-bar-mode
   (if (eq system-type 'darwin)
       t
     nil))
  ;; Show square corners or arrows to denote
  ;; the edge of a buffer
  (indicate-buffer-boundaries 'left)
  ;; Visible flash on error rather than sound
  (visible-bell 1)
  ;; Scroll by line when going off edge of screen
  (scroll-conservatively 101)
  ;; High precision scroll
  (pixel-scroll-precision-mode t)
  ;; Resize by pixel rather than char
  (frame-resize-pixelwise t)
  ;; Preserve location on screen when scrolling
  ;; i.e. when C-v, if was 4 lines from bottom
  ;; then it is still 4 lines from bottom
  (scroll-preserve-screen-position t)
  ;; If C-v scroll, don't throw error if moving
  ;; to top or bottom and wasn't already there
  (scroll-error-top-bottom t)
  ;; By default, truncate lines at edge of screen
  (truncate-lines t)
  ;; Trash by default
  (delete-by-moving-to-trash t)
  :config
  ;; Default to UTF-8 where possible
  (set-default-coding-systems 'utf-8))

;; Put the fill-column line at line 80 and show it in prog modes
(use-package display-fill-column-indicator
  :hook prog-mode
  :custom
  (fill-column 80))

;; Enable xterm mouse support so I can use
;; it from the terminal
(use-package xt-mouse
  :config
  (add-hook
   'after-make-frame-functions
   (lambda (_)
     (xterm-mouse-mode t)))
  (add-hook
   'delete-frame-functions
   (lambda (_)
     (xterm-mouse-mode -1))))

;; Allow hiding minor modes
(use-package diminish
  :ensure t)

;; Bring up a menu when in partially completed key chord
(use-package which-key
  :diminish which-key-mode
  :custom (which-key-mode t))

;; Allow highlighting hex colors (don't enable by default)
(use-package rainbow-mode
  :ensure t)

;; Show a breadcrumb at the top of the screen
(use-package breadcrumb
  :ensure t
  :custom (breadcrumb-mode t))

;; When in a text mode, don't truncate lines but wrap them
(use-package simple
  :diminish visual-line-mode
  ;; [TODO] is the extra org mode necessary?
  :hook ((org-mode text-mode) . visual-line-mode)
  :custom
  ;; Please no tabs
  (indent-tabs-mode nil)
  ;; Kill region default to word if no region selected
  (kill-region-dwim 'emacs-word)
  :bind
  ;; More dwim
  ("M-u" . upcase-dwim)
  ("M-l" . downcase-dwim)
  ("M-c" . capitalize-dwim))

;; Load the theme from the nix settings. Has to
;; be this way to avoid an error on loading
;; i.e. needs to be deferred
(if (daemonp)
    (add-hook 'after-make-frame-functions
              (lambda (frame)
                (with-selected-frame frame (load-theme my/theme t))))
  (add-hook 'after-init-hook (lambda ()
                               (load-theme my/theme t))))

(use-package frame
  :preface
  ;; Update if macOS ever supports alpha-background
  (defvar my/alpha-setting (if (string-match-p "PGTK"
                                               system-configuration-features)
                               `(alpha-background . ,(max 0 (- my/opacity 5)))
                             `(alpha . ,(min 100 (+ my/opacity 5)))))
  :custom
  (default-frame-alist `(;; Alpha settings
                         ,my/alpha-setting
                         ;; Make the title bar be the background color
                         (ns-transparent-titlebar . t)
                         ;; Don't show vertical or horizontal scroll bars
                         (vertical-scroll-bars . nil)
                         (horizontal-scroll-bars . nil))))

(use-package cus-face
  :custom-face
  ;; Load face settings from nix-settings
  (default ((t ( :family ,my/font-family-fixed-pitch
                 :height ,(* my/font-size 10)))))
  (variable-pitch ((t (:family ,my/font-family-variable-pitch))))
  (fixed-pitch ((t (:family ,my/font-family-fixed-pitch))))
  ;; Make string face italic
  (font-lock-string-face ((t (:slant italic)))))

;; Use ligatures, only prog-mode currently
(use-package ligature
  :ensure t
  :custom
  (global-ligature-mode t)
  :config
  (ligature-set-ligatures 'prog-mode '("==" "!=" ">=" "<=" "->" "=>"
                                       ".." "..." "++" "+=" "::=" "__"
                                       "===" "!==" "|>" ("[" "[[:alnum:]]+]"))))

;; Emacs dashboard
(use-package dashboard
  :ensure t
  :custom
  ;; Center the dashboard
  (dashboard-center-content t)
  ;; Make it the default buffer choice
  (initial-buffer-choice (lambda () (dashboard-refresh-buffer)))
  :hook
  ;; Refresh the dashboard after init
  (after-init-hook . dashboard-refresh-buffer)
  :bind
  ;; Add global keybinding to open dashboard
  ("C-x C-a d" . dashboard-refresh-buffer)
  ;; n and p to move forward/backward
  ( :map dashboard-mode-map
    ("n" . dashboard-next-line)
    ("p" . dashboard-previous-line))
  :config
  ;; Initialize dashboard
  (dashboard-setup-startup-hook))

;; Add Bible verse VotD to the dashboard
(use-package bible-gateway
  :ensure t
  :after dashboard
  :custom (dashboard-footer-messages (list (bible-gateway-get-verse))))

;; Eglot used for LSP
(use-package eglot
  :defer t
  :functions eglot-completion-at-point
  :custom
  ;; This fixes some weird line height changes on Darwin
  (eglot-code-action-indicator "*")
  ;; Enable semantic tokens
  (eglot-semantic-tokens-mode t)
  :hook
  ;; Hook into a variety of prog modes
  (( c-ts-mode bash-ts-mode fennel-mode go-ts-mode haskell-mode
     nix-mode java-ts-mode js-ts-mode
     lua-ts-mode rustic-mode scala-mode) . eglot-ensure)
  :preface
  ;; I don't know why eglot started
  ;; including :cancel-on-quit, but
  ;; jsonrpc claims it doesn't exist
  ;; [TODO] try removing at some point
  (defun remove:cancel-on-quit (args)
    (let ((server (car args))
          (kv (cdr args)))
      (cons server (map-delete kv :cancel-on-quit))))
  :config
  (advice-add 'jsonrpc-request :filter-args #'remove:cancel-on-quit))

;; Dape for DAP support
(use-package dape
  :ensure t
  :defer t)

(use-package treesit
  :functions
  treesit-node-at
  :custom
  ;; Max treesit font locking
  (treesit-font-lock-level 4)
  ;; Always use treesit if possible
  (treesit-enabled-modes t))

(use-package flymake
  :defer t
  ;; Show diagnostics inline at end of line
  :custom (flymake-show-diagnostics-at-end-of-line t)
  :hook emacs-lisp-mode)

(use-package skeleton :defines skeleton-positions)

(defun my/skeleton-indent-afterwards ()
  "Indent after inserting skeleton."
  (indent-region (car (last skeleton-positions)) (car skeleton-positions)))

(define-skeleton fundamental-skeleton-current-file
  "Insert the name of the current file."
  nil ;; no prompt
  > (file-name-nondirectory (buffer-file-name)))

(define-skeleton fundamental-skeleton-current-date
  "Insert the date."
  nil ;; no prompt
  > (format-time-string "%Y-%m-%d"))

(defun my/longest-line (str)
  "Return length of longest single line in `STR'."
  (seq-max (mapcar 'string-width (split-string str "\n"))))

(define-skeleton fundamental-skeleton-heading
  "Generate surrounded heading."
  ""
  '(setq str (skeleton-read "Title: "))
  > (make-string (my/longest-line str) ?=) \n
  > str \n
  > (make-string (my/longest-line str) ?=))

(defun my/add-skeleton-abbrevs (table pairs)
  "Add a `PAIRS' mapping words to skeletons to a given abbrev table `TABLE'."
  (dolist (pair pairs)
    (let ((name (car pair))
          (fn (cdr pair)))
      (define-abbrev table name "" fn 1))))

(defun my/add-fundamental-snippets (table)
  "Add the list of snippets for fundamental mode to abbrev table `TABLE'."
  (define-abbrev table "shr" "¯\\_(ツ)_/¯" nil 1)
  (my/add-skeleton-abbrevs table '(("here" . fundamental-skeleton-current-file)
                                   ("now" . fundamental-skeleton-current-date)
                                   ("heading" . fundamental-skeleton-heading))))

(use-package lisp
  :bind ("M-\"" . my/insert-quote)
  :preface
  (defun my/insert-quote (&optional arg)
    "Surround the region with quotes"
    (interactive "P")
    (insert-pair arg ?\" ?\")))

(use-package prog-mode
  :bind
  ;; Shift return to continue writing in a comment
  ( :map prog-mode-map
    ("S-<return>" . comment-indent-new-line)))

;; Configuring markdown mode
(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :config
  (my/add-fundamental-snippets markdown-mode-abbrev-table))

(use-package nix-mode
  :ensure t
  :config
  (my/add-fundamental-snippets nix-mode-abbrev-table))

(define-skeleton LaTeX-skeleton-begin
  "Insert LaTeX begin and end tags."
  '(setq str (skeleton-read "Type: "))
  > "\\begin{" str "}" \n
  > \n
  > "\\end{" str "}")

(defun my/add-LaTeX-snippets (table)
  "Add snippets related to LaTeX to the abbrev table `TABLE'."
  (my/add-fundamental-snippets table)
  (define-abbrev table "ria" "\\rightarrow" nil 1)
  (my/add-skeleton-abbrevs table '(("begin" . LaTeX-skeleton-begin))))

(use-package face-remap
  :hook (org-mode . variable-pitch-mode))

(use-package org
  :defer 5
  :diminish org-indent-mode
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
   ;; Different font sizes for headings
   '(org-level-1 ((t (:weight bold :height 1.5))))
   '(org-level-2 ((t (:weight bold :height 1.4))))
   '(org-level-3 ((t (:weight bold :height 1.3))))
   '(org-level-4 ((t (:weight bold :height 1.2))))
   '(org-level-5 ((t (:weight bold :height 1.1))))
   '(org-level-6 ((t (:weight bold))))
   '(org-level-7 ((t (:weight bold))))
   '(org-level-8 ((t (:weight bold)))))
  ;; Use org-tempo
  (add-to-list 'org-modules 'org-tempo)
  ;; Add LaTeX snippets here
  (my/add-LaTeX-snippets org-mode-abbrev-table)
  ;; Load various babel langauges [TODO] clean this code
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (R . t)
     (jupyter . t)
     (shell . t)
     (scala-cli . t))))

;; [TODO] what does this do?
(diminish 'buffer-face-mode)

;; Configure Karthik's org latex preview
(use-package org-latex-preview
  :defer t
  :after org
  ;; Enable in org mode by default
  :hook org-mode
  :custom
  ;; Enable live update
  (org-latex-preview-mode-display-live t)
  ;; Low delay
  (org-latex-preview-mode-update-delay 0.1)
  :config
  ;; Fix latex on emacs path but not zsh path
  (setcdr (assoc "pdflatex" org-latex-preview-compiler-command-map)
          (executable-find "latex")))

;; Nicer looking org mode
(use-package org-modern
  :ensure t
  :custom
  ;; Replace with custom stars, see below
  (org-modern-star 'replace)
  ;; Configure stars (one glyph missing in default with Maple Mono NF CN)
  (org-modern-replace-stars "◉○◈◇✿") ; replace the last glyph
  :hook org-mode)

;; Org modern indent
(use-package org-modern-indent
  :hook org-modern-mode)

(use-package ox-latex
  :preface
  (defun my/pandoc-latex-to-docx (texfile &optional _)
    "Convert latex doc to docx using pandoc"
    (let ((infile (shell-quote-argument texfile))
          (outfile (shell-quote-argument
                    (format "%s.docx" (substring texfile 0 -4)))))
      (shell-command (format "pandoc %s -o %s" infile outfile))))
  (defun my/org-latex-export-to-docx ( &optional async subtreep
                                       visible-only body-only ext-plist)
    "Org export to docx using pandoc on a generated latex."
    (interactive)
    (let ((outfile (org-export-output-file-name ".tex" subtreep)))
      (org-export-to-file 'latex outfile
        async subtreep visible-only body-only ext-plist
        #'my/pandoc-latex-to-docx)))
  :config
  ;; Add our custom docx exporter
  (org-export-define-derived-backend 'docx 'latex
    :menu-entry
    '(?l 1
         ((?d "As LaTeX file (Docx)" my/org-latex-export-to-docx)))))

(use-package jupyter
  :ensure t
  :preface
  (defun my/babel-render-export ()
    "Render the HTML output of an org babel block."
    (interactive)
    (org-mark-element)
    (forward-line 2)
    (org-beginning-of-line)
    (exchange-point-and-mark)
    (forward-line -3)
    (org-end-of-line)
    (shr-render-region (mark) (point))))

(use-package engrave-faces
  :ensure t
  ;; Fontify using the engrave-faces backend
  :custom (org-latex-src-block-backend 'engraved))

(define-skeleton java-skeleton-def-main
  "Generate java main class/function."
  ""
  @
  "public class " (capitalize
                   (file-name-nondirectory
                    (file-name-sans-extension (buffer-name)))) " {" \n
  "public static void main(String[] args) {" \n
  _ \n
  "}" \n
  "}"
  @
  '(my/skeleton-indent-afterwards))

(define-skeleton java-skeleton-println
  "Generate println statement."
  ""
  > "System.out.println(" (skeleton-read "text: ") ");" \n
  > _)

(defun my/add-java-snippets (table)
  "Add java snippets to the abbrev table `TABLE'."
  (my/add-fundamental-snippets table)
  (my/add-skeleton-abbrevs table '(("defmain" . java-skeleton-def-main)
                                   ("pr" . java-skeleton-println))))

(use-package java-ts-mode
  :config
  ;; Configure java-ts-mode to use java abbrevs
  (my/add-java-snippets java-ts-mode-abbrev-table))

(use-package scala-mode
  :ensure t
  :hook
  ;; Disable type formatting for scala (caused freezing)
  (scala-mode . (lambda ()
                  (setq-local eglot-ignored-server-capabilities
                              '(:documentOnTypeFormattingProvider))))
  ;; Prettify replace symbols (like Int => Z)
  (scala-mode . (lambda ()
                  (setq prettify-symbols-alist scala-prettify-symbols-alist)
                  (prettify-symbols-mode)))
  :config
  ;; Allow build.sbt as a project root
  (add-to-list 'project-vc-extra-root-markers "build.sbt")
  :bind
  ;; Add keybinds for running and testing
  ( :map scala-mode-map
    ("C-c C-r" . sbt-do-run)
    ("C-c C-t" . sbt-do-test)))
(use-package sbt-mode
  :functions
  sbt-do-run
  sbt-do-test
  :ensure t)
(use-package scala-cli-repl
  ;; Pin to scala 3
  :custom (ob-scala-cli-default-params '(:scala-version "3.0.0")))

(use-package rust-mode
  :ensure t
  :custom
  ;; Make rust use treesi
  (rust-mode-treesitter-derive t)
  ;; Do format when saving
  (rust-format-on-save t))
(use-package rustic
  :ensure t
  :after rust-mode
  ;; We do our own management of LSP
  :custom (rustic-lsp-setup-p nil)
  :config
  ;; Based on the basic snippets
  (my/add-fundamental-snippets rustic-mode-abbrev-table))

(use-package lua-ts-mode
  :config
  ;; Add snippets
  (my/add-fundamental-snippets lua-ts-mode-abbrev-table))

(use-package zig-mode
  :ensure t
  :diminish zig-format-on-save-mode
  :config
  ;; Add snippets
  (my/add-fundamental-snippets zig-mode-abbrev-table))

(defun my/default-header-guard-name ()
  "Default header guard created by upcase the file name."
  (concat
   (upcase
    (file-name-nondirectory
     (file-name-sans-extension (buffer-file-name)))) "_H"))

(define-skeleton c-skeleton-guard
  "Generate header guard."
  ""
  '(setq str (skeleton-read "Header: " (my/default-header-guard-name)))
  "#ifndef " str \n
  "#define " str \n
  \n
  _ \n
  \n
  "#endif /* " str " */")

(define-skeleton c-skeleton-doxy-header
  "Doxygen comment for header."
  ""
  @
  "/**" \n
  " * @file " (file-name-nondirectory (buffer-file-name)) \n
  " * @author " (skeleton-read "Author: " nil nil) \n ;; TODO default author
  " * @brief " (skeleton-read "Brief: " nil nil) \n
  " * @date " (format-time-string "%Y-%m-%d") \n
  " */"
  @
  '(my/skeleton-indent-afterwards))

(define-skeleton c-skeleton-doxy-fn
  "Doxygen comment for a function."
  ""
  @
  "/**" \n
  " * @brief " (skeleton-read "Brief: ") \n
  " *" \n
  " * " (skeleton-read "Description: ") \n
  " *" \n
  ("Param: " " * @param " str \n)
  " * @return " (skeleton-read "Returns: ") \n
  " */"
  @
  '(my/skeleton-indent-afterwards))

(defun my/add-c-snippets (table)
  "Add C based snippets to `TABLE'."
  (my/add-fundamental-snippets table)
  (my/add-skeleton-abbrevs table '(("guard" . c-skeleton-guard)
                                   ("doxyheader" . c-skeleton-doxy-header)
                                   ("doxyfn" . c-skeleton-doxy-fn))))

(use-package c-ts-mode
  :custom
  ;; Offset of 4 is good
  (c-ts-mode-indent-offset 4)
  ;; Doxygen integration is great
  (c-ts-mode-enable-doxygen t)
  :config
  ;; Register C snippets
  (my/add-c-snippets c-ts-mode-abbrev-table))

(define-skeleton python-skeleton-doc-func
  "Generate doc comment for function."
  ""
  "\"\"\"" (skeleton-read "Brief: ") \n
  \n
  (skeleton-read "Long: ") \n
  \n
  "Args:" \n
  ("Arg: " "    " str \n)
  \n
  "Returns:" \n
  "    " (skeleton-read "Returns: ") \n
  \n
  "Raises:" \n
  ("Exception: " "    " str \n)
  "\"\"\"")

(define-skeleton python-skeleton-main-fn
  "Generate main-func paradigm."
  ""
  "def main():" \n
  > _ \n
  > "pass" \n
  \n
  "if __name__ == '__main__':" \n
  > "main()")

(defun my/add-python-snippets (table)
  "Register python snippets into `TABLE'."
  (my/add-fundamental-snippets table)
  (my/add-skeleton-abbrevs table '(("dfunc" . python-skeleton-doc-func)
                                   ("mainf" . python-skeleton-main-fn))))

(use-package python
  :config
  ;; Add python snippets
  (my/add-python-snippets python-ts-mode-abbrev-table))

(use-package js
  :config
  ;; Basic snippets
  (my/add-fundamental-snippets js-ts-mode-abbrev-table))

(use-package fennel-mode
  :ensure t
  :mode ("\\.fnl\\'" . fennel-mode)
  :config
  (my/add-fundamental-snippets fennel-mode-abbrev-table))

(use-package just-ts-mode
  :ensure t)

(use-package haskell-mode
  :ensure t)

(use-package swift-mode
  :ensure t
  :config
  ;; [TODO] is this not already in the default?
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 '(swift-mode . ("sourcekit-lsp")))))

(use-package ada-ts-mode
  :ensure t)

(use-package ess
  :ensure t
  :custom
  ;; Smaller indent b/c that's how it is preferred
  (ess-indent-offset 2)
  :config
  ;; Necessary for my custom C-<return>
  (treesit-parser-create 'r)
  :functions
  ess-eval-region
  :preface
  (defun my/ess-eval-top-level-expression (&optional vis)
    "Evaluate the top-most expression at point."
    (interactive "P")
    (let ((current (treesit-node-at (point))))
      (while (not (string= "program"
                           (treesit-node-type (treesit-node-parent current))))
        (setq current (treesit-node-parent current)))
      (ess-eval-region (treesit-node-start current)
                       (treesit-node-end current) vis))))
(use-package ess-r-mode
  :bind
  ;; Custom eval is bound to C-<return> in place of the old one
  ( :map ess-r-mode-map
    ("C-<return>" . my/ess-eval-top-level-expression)))

(use-package elisp-mode
  :custom
  ;; Semantic fonitifcation is nice
  (elisp-fontify-semantically t))

(use-package vertico
  :ensure t
  :custom
  ;; Cycle vertico
  (vertico-cycle t)
  ;; Enable ootb
  (vertico-mode t))

(use-package vertico-posframe
  :ensure t
  :after vertico
  :custom
  ;; Vertico in posframe [TODO] what about mini-frame?
  (vertico-posframe-mode 1))

(use-package marginalia
  :ensure t
  :custom
  ;; Enable marginalia
  (marginalia-mode 1))

(use-package orderless
  :ensure t
  :custom
  ;; Use the orderless completion
  (completion-styles '(orderless basic))
  ;; [TODO] why?
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package savehist
  :custom
  ;; Save history between sessions
  (savehist-mode 1))

(use-package consult
  :ensure t
  :custom
  ;; Constant update
  (consult-async-refresh-delay 0)
  (consult-async-min-input 1)
  ;; Replace builtin commands with better ones
  :bind (("C-x p f" . consult-fd)
         ("C-x p g" . consult-ripgrep)
         ("C-x b" . consult-buffer)
         ("C-x p b" . consult-project-buffer)
         ("M-g g" . consult-goto-line)
         ("M-y" . consult-yank-pop)))

(use-package cape
  :ensure t
  :after corfu
  :init
  ;; Define super capfs for various modes
  (defvar my/eglot-capf
    (cape-capf-super #'eglot-completion-at-point #'cape-abbrev))
  (defvar my/elisp-capf
    (cape-capf-super #'cape-abbrev #'cape-dabbrev #'elisp-completion-at-point))
  (defvar my/org-capf
    (cape-capf-super #'cape-abbrev #'cape-elisp-block))
  (defvar my/generic-capf
    (cape-capf-super #'cape-abbrev))

  (defun my/cape-capf-set ()
    "Setup capfs depending on the mode."
    (interactive)
    (setq-local completion-at-point-functions
                (list #'cape-file
                      (cond ((equal major-mode #'org-mode)
                             my/org-capf)
                            ((or (equal major-mode #'emacs-lisp-mode)
                                 (equal major-mode #'lisp-interaction-mode))
                             my/elisp-capf)
                            ((and (fboundp 'eglot-managed-p) (eglot-managed-p))
                             my/eglot-capf)
                            (t
                             my/generic-capf)))))
  :hook (after-change-major-mode . my/cape-capf-set))

(use-package corfu
  :ensure t
  ;; tab completion
  :bind ( :map corfu-mode-map
          ("S-<tab>" . completion-at-point)
          ("<backtab>" . completion-at-point))
  :custom
  ;; Always enabled
  (global-corfu-mode t)
  ;; Allow cycling
  (corfu-cycle t)
  ;; Popup the documentation after half a second [TODO] reduce?
  (corfu-popupinfo-delay '(0.5 . 0.5))
  :hook prog-mode)
(use-package corfu-popupinfo
  :after corfu
  :hook corfu-mode)

;; [TODO] fix suggestion in org mode at least not being
;;        anything other than a simple dict autocomplete (abbrev not showing?)
(use-package completion-preview
  :diminish completion-preview-mode
  :hook corfu-mode
  ;; Show after two chars
  :custom (completion-preview-minimum-symbol-length 2)
  :config
  ;; Allow org movement commands to still trigger completion
  (setq completion-preview-commands
        (append completion-preview-commands
                '(org-self-insert-command org-delete-backward-char))))

(use-package kind-icon
  :ensure t
  :after corfu
  :custom
  ;; Add icons to the right side
  (corfu-margin-formatters (list #'kind-icon-margin-formatter)))

(use-package elec-pair
  :functions electric-pair-default-inhibit
  :custom
  ;; Electric pair ootb [TODO] not in org?
  (electric-pair-mode t))

(use-package avy
  :ensure t
  ;; Easy jump / yank
  :bind (("M-j" . avy-goto-char-timer)))

;; Show documentation
(use-package eldoc
  :diminish eldoc-mode)
(use-package eldoc-box
  :ensure t
  :after eglot
  ;; Show doc inline
  :bind ( :map eglot-mode-map
          ("C-c C-e" . 'eldoc-box-help-at-point)))

(defvar my/radio-channel-location
  "~/.config/sops-nix/secrets/emacs-radio-channels.el")

(defun my/radio-play ()
  "Ask the user for a radio channel to play."
  (interactive)
  (let* ((my/radio-channels (my/user-secret-else my/radio-channel-location nil))
         (choice (completing-read "Station:"
                                  (seq-map (lambda (pair)
                                             (car pair)) my/radio-channels)))
         (association (assoc choice my/radio-channels)))
    (message "playing %s" choice)
    (emms-play-url (if association
                       (cdr association)
                     choice))))

(use-package emms
  :ensure t
  :bind (("C-x C-a p e" . emms)
         ("C-x C-a p p" . emms-start)
         ("C-x C-a p s" . emms-stop)
         ("C-x C-a p r" . my/radio-play))
  :custom
  ;; mpv backend for emms
  (emms-player-list '(emms-player-mpv))
  :config
  (require 'emms-setup)
  (emms-minimalistic))

(use-package vscode-icon
  :ensure t)

(use-package dired
  :functions
  dired-hide-details-mode
  :custom
  ;; B/c Darwin is weird
  (dired-use-ls-dired (not (eq system-type 'darwin)))
  :hook
  ;; Reduce columns and add icons (only if not already
  ;; in dired-sidebar)
  (dired-mode . (lambda ()
                  (require 'dired-sidebar)
                  (unless (my/dired-sidebar-bufferp)
                    (setq-local dired-hide-details-preserved-columns
                                '(1 3 5 6 7 8))
                    (dired-hide-details-mode)
                    (add-hook 'dired-after-readin-hook
                              'dired-sidebar-tui-dired-display nil t)))))

(use-package dired-sidebar
  :ensure t
  :after vscode-icon
  :bind ("C-x C-d" . dired-sidebar-toggle-sidebar)
  :functions
  dired-sidebar-tui-dired-display
  dired-sidebar-buffer
  :hook
  ;; Auto-revert
  (dired-sidebar-mode . (lambda ()
                          (unless (file-remote-p default-directory)
                            (auto-revert-mode))))
  :custom
  (dired-sidebar-theme 'vscode)
  :preface
  (defun my/dired-sidebar-bufferp ()
    "Check if the current buffer is a dired-sidebar buffer."
    (eq (current-buffer) (dired-sidebar-buffer))))

(use-package dired-preview
  :ensure t
  :custom
  ;; Always dired preview [TODO] disable, this is getting annoying?
  (dired-preview-global-mode t)
  ;; Show preview quickly
  (dired-preview-delay 0.1))

(use-package pdf-tools
  :ensure t
  :hook
  :config
  ;; Compile in the pdf tools
  (pdf-tools-install nil t))
(use-package pdf-roll
  :hook pdf-view-mode)

;; Offbrand pdf-tools
(use-package page-view)

(use-package eat
   :ensure t)

;; Custom popup terminal
(use-package toggleterm
  :defer nil
  :bind ("C-x C-a t" . toggleterm-dwim))

(use-package gnus
  :defines
  gnus-newsrc-alist
  gnus-tmp-group
  :functions
  gnus-collect-urls
  gnus-browse-exit
  gnus-browse-toggle-subscription-at-point
  gnus-browse-foreign-server)

(defun my/subscribe-feed-url (method url)
  "Subscribe to a feed at `URL' of type `METHOD' (nnnrss, nnatom, etc.)."
  (gnus-browse-foreign-server (list method url))
  (with-current-buffer "*Gnus Browse Server*"
    (let ((colon (string-match ":" (buffer-string))))
      (message "%s" (buffer-string))
      (gnus-browse-toggle-subscription-at-point colon))
    (gnus-browse-exit)))

(defvar my/feeds-file "~/.config/sops-nix/secrets/emacs-feeds.el")

(defun my/newsrc-contains (method-url)
  "Check if newrc already contains `METHOD-URL'."
  (seq-filter (lambda (entry)
                (string-prefix-p method-url (nth 0 entry)))
              gnus-newsrc-alist))

(defun my/add-missing-feeds ()
  "Add all feeds not already in newrc there."
  (dolist (feed (my/user-secret-else my/feeds-file nil))
    (let* ((method+url (nth 0 feed))
           (split (string-split method+url "+"))
           (method (read (car split)))
           (url (cl-second split)))
      (unless (my/newsrc-contains method+url)
        (message "adding feed %s" method+url)
        (my/subscribe-feed-url method url)))))

;; I don't really like the qualified name,
;; and the non-qualified name isn't as
;; easily customizable
(defun gnus-user-format-function-G (_)
  "Nicer formatting?"
  (let* ((url-and-method (nth 0 (string-split gnus-tmp-group ":")))
         (mapped (assoc url-and-method
                        (my/user-secret-else my/feeds-file nil))))
    (if (null mapped)
        gnus-tmp-group
      (cdr mapped))))

(defun my/select-and-play-url ()
  "Play a given URL in emms."
  (interactive)
  (let ((urls (gnus-collect-urls)))
    (cond ((length< urls 1) (message "no URLs found"))
          ((length= urls 1) (emms-play-url (car urls)))
          ((length> urls 1) (emms-play-url (completing-read "URLs: " urls))))))

(use-package gnus
  :custom
  ;; [TODO] explain
  (gnus-group-line-format "%M%S%p%P%5y:%B%(%uG%)\n")
  ;; Configure showing feeds
  (gnus-parameters '(("\\(nnnrss\\|nnatom\\)+.*"
                      (display . all)
                      (gnus-article-sort-functions
                       '((not gnus-article-sort-by-date)))
                      (gnus-show-threads nil))))
  (gnus-permanently-visible-groups "\\(nnnrss\\|nnatom\\)+.*")
  :bind (("C-x C-a g" . gnus)
         :map gnus-article-mode-map
         ("C-c C-p" . my/select-and-play-url))
  :hook (gnus-setup-news . my/add-missing-feeds))

(use-package files
  :preface
  (defun my/find-file-massive-basic ()
    "If a file is large, remove features to not freeze."
    (when (and (> (buffer-size) (* 256 1024)) (or (derived-mode-p 'text-mode)
                                                  (derived-mode-p 'prog-mode)))
      (setq buffer-read-only t)
      (buffer-disable-undo)
      (text-mode)))
  :hook (find-file . my/find-file-massive-basic)
  :custom
  ;; Put backups in ~/.emacs.d rather than scattered on FS
  (backup-directory-alist `(("." . ,(concat user-emacs-directory "backups"))))
  ;; Don't create lockfiles for crying out loud
  (create-lockfiles nil)
  ;; Don't save my abbrevs, they're defined here
  (save-abbrevs nil))

(use-package vundo
  :ensure t
  ;; Vundo is amazing
  :bind ("C-?" . vundo))

(use-package undo-fu-session
  :ensure t
  ;; Save undo history
  :custom (undo-fu-session-global-mode t))

;; Ibuffer instead of whatever it was before
(use-package ibuffer
  :bind ("C-x C-b" . ibuffer)
  :custom (ibuffer-auto-mode t))

;; Grouping ibuffer by project root
(use-package ibuffer-vc
  :ensure t
  :bind ( :map ibuffer-mode-map
          ("/ V" . ibuffer-vc-set-filter-groups-by-vc-root)))

(use-package delsel
  ;; Delete selection when typing and region active
  :custom (delete-selection-mode t))

(use-package indent-bars
  :ensure t
  :hook prog-mode
  :custom
  ;; Show indent bars on ts
  (indent-bars-ts-support t)
  ;; Nicer colors
  (indent-bars-color '(highlight :blend 0.6))
  ;; Show current depth differently
  (indent-bars-highlight-current-depth '(:face default :blend 1.0))
  ;; Fix scope for python
  (indent-bars-treesitter-scope '((python function_definition class_definition
                                          for_statement if_statement
                                          with_statement while_statement))))

(use-package sqlite-mode
  :bind
  ;; Nice movement commands in sqlite
  ( :map sqlite-mode-map
    ("n" . next-line)
    ("p" . previous-line)))

(use-package project
  :custom
  ;; Show in mode line
  (project-mode-line t)
  ;; Clean up project mode line
  (project-mode-line-format '(:eval
                              (if (project-current)
                                  (concat
                                   " ["
                                   (substring (project-mode-line-format) 1)
                                   "]")))))

(use-package vc-git
  :config
  ;; I really just need to be able to use ¯\_(ツ)_/¯
  (my/add-fundamental-snippets vc-git-log-edit-mode-abbrev-table))

(use-package vc-jj
  :ensure t)

(use-package recentf
  :custom
  ;; Keep track of recently visited files
  (recentf-mode t)
  ;; Increase the limit
  (recentf-max-saved-items 50)
  :bind ("C-x C-r" . recentf))

(use-package saveplace
  :custom
  ;; Remember where last in file on reopen
  (save-place-mode t)
  ;; Autosave every 3 seconds
  (save-place-autosave-interval 3.0))

(use-package exec-path-from-shell
  :ensure t
  :custom
  ;; [TODO] not sure why this is here
  (exec-path-from-shell-arguments nil)
  :config
  ;; This way we can preserve our linkage to e.g. VLC
  (let ((nix-store-exec-path
         (seq-filter (lambda (item)
                       (string-prefix-p "/nix/store" item)) exec-path)))
    (exec-path-from-shell-initialize)
    (setq exec-path (append nix-store-exec-path exec-path))
    (setenv "PATH"
            (string-join (cons (getenv "PATH") nix-store-exec-path) ":"))))

;; Allow hiding code blocks
(use-package hideshow
  :diminish hs-minor-mode
  :hook (prog-mode . hs-minor-mode)
  :custom (hs-show-indicators t))

;; Other hide blocks
(use-package outline
  :diminish (outline-minor-mode))

;; More hide blocks
(use-package outline-indent
  :ensure t
  :custom
  ;; Customize symbol
  (outline-indent-ellipsis " ▼"))

;; And treesit based hide blocks
(use-package treesit-fold
  :ensure t
  :custom
  (global-treesit-fold-mode t)
  ;; With the indicators, nice
  (global-treesit-fold-indicators-mode t))

;; And unify the fold types
(use-package kirigami
  :ensure t
  :bind ("C-<iso-lefttab>" . kirigami-toggle-fold))

(use-package ansi-color
  :functions
  ansi-color-apply-on-region
  :preface
  (defun my/colorize-buffer ()
    "Colorize the current buffer."
    (let ((inhibit-read-only t))
      (ansi-color-apply-on-region (point-min) (point-max)))))

(use-package compile
  :hook (compilation-filter . my/colorize-buffer)
  :custom
  ;; Follow output
  (compilation-scroll-output t))

(use-package paren
  :custom
  ;; Show parens
  (show-paren-mode t)
  ;; Highlight expression rather than the pair itself
  (show-paren-style 'expression))

(use-package mwheel
  :custom
  ;; Mouse improvements
  (mouse-wheel-tilt-scroll t)
  (mouse-wheel-flip-direction t))

;; Use editorconfig
(use-package editorconfig
  :custom (editorconfig-mode t)
  :diminish editorconfig-mode)

;; Easier window switching
(use-package ace-window
  :ensure t
  :bind
  ("M-o" . ace-window))

;; Dictionary support
(use-package ispell
  :custom
  (ispell-program-name "aspell"))
(use-package flyspell
  :custom
  ;; Default to english yay
  (flyspell-default-dictionary "en"))

;; Expanding the region, treesit-based
(use-package expreg
  :ensure t
  :bind
  ("C-;" . expreg-expand)
  ("C-:" . expreg-contract))

(use-package word-count
  :hook org-mode)

;; Direnv support
(use-package envrc
  :ensure t
  :after exec-path-from-shell
  ;; This needs to be hooked last to ensure it runs first
  :hook (after-init . envrc-global-mode)
  :functions envrc-propagate-environment
  :config
  ;; Advice a few poorly acting modes
  (dolist (fn '(Man-completion-table sql-sqlite my/org-latex-export-to-docx))
    (advice-add fn :around #'envrc-propagate-environment)))

(provide 'init)
;;; init.el ends here
