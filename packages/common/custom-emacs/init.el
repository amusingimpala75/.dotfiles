;;; package --- Custom Emacs Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;; Some changes were suggested by emacs-solo
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

;; Bring up a menu when in partially completed key chord
(use-package which-key
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
  :hook
  (text-mode . visual-line-mode)
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
                         (horizontal-scroll-bars . nil)
                         (fullscreen . maximized))))

(use-package cus-face
  :custom-face
  ;; Load face settings from nix-settings
  (default ((t ( :family ,my/font-family-fixed-pitch
                 :height ,(* my/font-size 10)))))
  (variable-pitch ((t (:family ,my/font-family-variable-pitch))))
  (fixed-pitch ((t (:family ,my/font-family-fixed-pitch)))))

(use-package font-lock
  :config
  (custom-set-faces '(font-lock-string-face ((t (:slant italic))))))

;; Use ligatures, only prog-mode currently
(use-package ligature
  :ensure t
  :custom
  (global-ligature-mode t)
  :config
  (ligature-set-ligatures '(prog-mode org-mode)
                          '("==" "!=" ">=" "<=" "->" "=>"
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
  :custom
  (flymake-show-diagnostics-at-end-of-line 'fancy)
  (flymake-indicator-type 'margins)
  :hook emacs-lisp-mode)

(defun my/longest-line (str)
  "Return length of longest single line in `STR'."
  (seq-max (mapcar 'string-width (split-string str "\n"))))

(use-package prog-mode
  :bind
  ;; Shift return to continue writing in a comment
  ( :map prog-mode-map
    ("S-<return>" . comment-indent-new-line)))

;; Configuring markdown mode
(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode))

(use-package eglot
  :defines
  eglot-workspace-configuration
  eglot-server-programs)

(use-package nix-mode
  :ensure t
  :config
  (setq-default
   eglot-workspace-configuration
   (plist-put
    eglot-workspace-configuration
    :nixd
    '(:options
      ( :nixos (:expr "(builtins.getFlake \"/home/murrayle23/.dotfiles\")).nixosConfigurations.wsl-nix.options")
        :nix-darwin (:expr "(builtins.getFlake \"/home/murrayle23/.dotfiles\").darwinConfigurations.Lukes-MacBook-Air.options")
        :home-manager (:expr "(builtins.getFlake \"/home/murrayle23/.dotfiles\").legacyPackages.x86_64-linux.homeConfigurations.murrayle23.options"))))))

(use-package face-remap
  :hook (org-mode . variable-pitch-mode))

(use-package org
  :defer 5
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
  ;; Use org-tempo
  (add-to-list 'org-modules 'org-tempo)
  ;; Load various babel langauges [TODO] clean this code
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (R . t)
     (jupyter . t)
     (shell . t)
     (scala-cli . t))))

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
  :ensure t
  :hook org-modern-mode)

(use-package ox-pandoc
  :ensure t)

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
  :ensure t
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
  :custom (rustic-lsp-setup-p nil))

(use-package zig-mode
  :ensure t)

(use-package c-ts-mode
  :custom
  ;; Offset of 4 is good
  (c-ts-mode-indent-offset 4)
  ;; Doxygen integration is great
  (c-ts-mode-enable-doxygen t))

(use-package fennel-mode
  :ensure t
  :mode ("\\.fnl\\'" . fennel-mode))

(use-package just-ts-mode
  :ensure t)

(use-package haskell-mode
  :ensure t)

(use-package swift-mode
  :ensure t
  :config
  (add-to-list
   'eglot-server-programs
   '(swift-mode . ("sourcekit-lsp"))))

(use-package eglot
  :config
  ;; Use rass for ts/js
  (setcdr
   (assoc
    '((js-mode :language-id "javascript")
      (js-ts-mode :language-id "javascript")
      (tsx-ts-mode :language-id "typescriptreact")
      (typescript-ts-mode :language-id "typescript")
      (typescript-mode :language-id "typescript"))
    eglot-server-programs)
   '("rass" "--" "typescript-language-server" "--stdio" "--" "biome" "lsp-proxy")))

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

(use-package groovy-mode
  :ensure t)

(use-package imacs-completion
  :ensure t)

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
                                             (car pair))
                                           my/radio-channels)))
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
  :ensure t
  :functions
  vscode-icon-for-file)

(use-package dired
  :functions
  dired-hide-details-mode
  dired-current-directory
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

(use-package pdf-tools
  :ensure t
  :config
  ;; Compile in the pdf tools
  (pdf-tools-install nil t))
;; (use-package pdf-roll
;;   :hook pdf-view-mode)

;; Nicer looking org mode editing (centered column)
(use-package olivetti
  :ensure t)

(use-package reader
  :ensure t)

(use-package nnnrss
  :ensure t)

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
  :custom
  (ibuffer-auto-mode t)
  (ibuffer-show-empty-filter-groups nil)
  (ibuffer-formats
   '(( mark modified read-only locked " "
       (icon 2 2 :left) (name 18 18 :left :elide) " "
       (size 9 -1 :right) " "
       (mode 16 16 :left :elide) " "
       filename-and-process)
     ( mark " "
       (name 16 -1) " "
       filename)))
  :preface
  (defun my/icon-for-buffer (buffer)
    (with-current-buffer buffer
      (cond
       ((buffer-file-name) (vscode-icon-for-file (buffer-file-name)))
       ((derived-mode-p 'dired-mode) (vscode-icon-for-file (dired-current-directory)))
       ((derived-mode-p 'eshell-mode) (vscode-icon-for-file "foo.sh"))
       (t nil))))
  :config
  (define-ibuffer-column icon
    (:name " ")
    (if-let* ((icon (my/icon-for-buffer buffer)))
        (propertize " " 'display icon)
      "  ")))

;; Grouping ibuffer by project root
(use-package ibuffer-vc
  :ensure t
  :bind
  ( :map ibuffer-mode-map
    ("/ V" . ibuffer-vc-set-filter-groups-by-vc-root))
  :hook
  (ibuffer . (lambda () (ibuffer-vc-set-filter-groups-by-vc-root))))

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
                                          with_statement while_statement)))
  ;; Don't unnecessarily draw intermediate lines
  (indent-bars-no-descend-lists 'skip))

(use-package sqlite-mode
  :bind
  ;; Nice movement commands in sqlite
  ( :map sqlite-mode-map
    ("n" . next-line)
    ("p" . previous-line)))

(use-package vc-jj
  :ensure t)

(use-package recentf
  :custom
  ;; Keep track of recently visited files
  (recentf-mode t)
  ;; Increase the limit
  (recentf-max-saved-items 200)
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
                       (string-prefix-p "/nix/store" item))
                     exec-path)))
    (exec-path-from-shell-initialize)
    (setq exec-path (append nix-store-exec-path exec-path))
    (setenv "PATH"
            (string-join (cons (getenv "PATH") nix-store-exec-path) ":"))))

;; Allow hiding code blocks
(use-package hideshow
  :hook (prog-mode . hs-minor-mode)
  :custom (hs-show-indicators t))

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
  :bind
  ("C-<iso-lefttab>" . kirigami-toggle-fold)
  ("C-S-<tab>" . kirigami-toggle-fold))

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
  :hook
  (prog-mode . show-paren-local-mode)
  :custom
  ;; Show parens
  (show-paren-delay 0)
  (show-paren-context-when-offscreen 'overlay))

(use-package mwheel
  :custom
  ;; Mouse improvements
  (mouse-wheel-tilt-scroll t)
  (mouse-wheel-flip-direction t))

;; Use editorconfig
(use-package editorconfig
  :custom (editorconfig-mode t))

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
(use-package dictionary
  :custom
  (dictionary-server "localhost"))

;; Expanding the region, treesit-based
(use-package expreg
  :ensure t
  :bind
  ("C-;" . expreg-expand)
  ("C-:" . expreg-contract))

(use-package surround
  :ensure t
  :bind-keymap ("M-'" . surround-keymap))

(use-package word-count
  :ensure t
  :hook org-mode)

(use-package agent-shell
  :ensure t)

(use-package scratch
  :ensure t
  :preface
  (defun my/create-scratch-buffer ()
    (save-excursion
      (goto-char (point-min))
      (insert (substitute-command-keys initial-scratch-message))
      (replace-regexp-in-region ";; " "" (point-min) (point-max))
      (comment-region (point-min) (point-max))))
  :hook
  (scratch-create-buffer . my/create-scratch-buffer))

(use-package persistent-scratch
  :ensure t
  :hook
  (after-init . persistent-scratch-setup-default)
  :custom
  (pesistent-scratch-scratch-buffer-p-function
   (lambda ()
     (or (persistent-scratch-default-scratch-buffer-p)
         scratch-buffer))))

(use-package casual
  :ensure t)

(use-package whitespace
  :hook (before-save . whitespace-cleanup))

(use-package isearch
  :custom
  (isearch-lazy-count t))

(use-package imacs-mode-line
  :ensure t)

(use-package imacs-shell
  :ensure t)

(use-package mb-depth
  :custom
  (minibuffer-depth-indicate-mode t))

(use-package subword
  :hook (after-init . global-subword-mode))

(use-package god-mode
  :ensure t
  :bind
  ("C-z" . god-local-mode)
  ( :map god-local-mode-map
    ("." . repeat))
  :preface
  (defun my/update-cursor-type ()
    (setq cursor-type (if god-local-mode 'box 'bar)))
  :hook
  (post-command . my/update-cursor-type)
  (after-init . god-mode-all)
  :config
  (add-to-list 'god-exempt-major-modes 'vterm-mode))

(use-package hl-line
  :custom
  (global-hl-line-mode t))

(use-package s
  :functions s-trim)

(use-package autorevert
  :custom
  (global-auto-revert-mode t))

;; Direnv support
(use-package envrc
  :ensure t
  :after exec-path-from-shell
  ;; This needs to be hooked last to ensure it runs first
  :hook (after-init . envrc-global-mode)
  :functions envrc-propagate-environment envrc--find-env-dir
  :config
  ;; Advice a few poorly acting modes
  (dolist (fn '( Man-completion-table sql-sqlite my/org-latex-export-to-docx
                 eshell-vterm-exec-visual))
    (advice-add fn :around #'envrc-propagate-environment)))

(provide 'init)
;;; init.el ends here
