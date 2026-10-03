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
  :hook
  ;;  Also see frame defaults
  (after-init . (lambda () (scroll-bar-mode -1))))

;; Disable tool bar
(use-package tool-bar
  :hook
  (after-init . (lambda () (tool-bar-mode -1))))

(use-package emacs
  :hook
  ;; Disable menu bar, unless it's on macOS ('cause it doesn't take
  ;; up any extra screen space there)
  (after-init
   . (lambda ()
       (menu-bar-mode
        (if (eq system-type 'darwin)
            t
          -1))))
  ;; High precision scroll
  (after-init . pixel-scroll-precision-mode)
  :custom
  ;; Show square corners or arrows to denote
  ;; the edge of a buffer
  (indicate-buffer-boundaries 'left)
  ;; Visible flash on error rather than sound
  (visible-bell 1)
  ;; Scroll by line when going off edge of screen
  (scroll-conservatively 101)
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
  ;; Disable bidirectional text for performance gain
  (bidi-display-reordering 'left-to-right)
  (bidi-paragraph-direction 'left-to-right)
  (bidi-inhibit-bpa t)
  ;; Don't refontify while still typing
  (redisplay-skip-fontification-on-input t)
  ;; Increase read process to improve lsp speeds
  (read-process-output-max (* 1 1024 1024))
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

(use-package term/xterm
  :custom
  (xterm-update-cursor t))

;; Bring up a menu when in partially completed key chord
(use-package which-key
  :hook
  (after-init . which-key-mode))

;; Allow highlighting hex colors (don't enable by default)
(use-package rainbow-mode
  :ensure t)

;; Show a breadcrumb at the top of the screen
(use-package breadcrumb
  :ensure t
  :hook
  (after-init . breadcrumb-mode))

(use-package simple
  :hook
  ;; When in a text mode, don't truncate lines but wrap them
  (text-mode . visual-line-mode)
  :custom
  ;; Please no tabs
  (indent-tabs-mode nil)
  ;; Kill region default to word if no region selected
  (kill-region-dwim 'emacs-word)
  ;; Save shared kill ring
  (save-interprogram-paste-before-kill t)
  ;; Dedupe kill ring
  (kill-do-not-save-duplicates t)
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

(defun my/prepend-emoji-font ()
  "Make it use the proper emoji fonts."
  (let ((font-family (if (eq system-type 'darwin)
                         "Apple Color Emoji"
                       "Noto Color Emoji")))
    (set-fontset-font t 'emoji (font-spec :family font-family))))

(use-package cus-face
  :custom-face
  ;; Load face settings from nix-settings
  (default ((t ( :family ,my/font-family-fixed-pitch
                 :height ,(* my/font-size 10)))))
  (variable-pitch ((t (:family ,my/font-family-variable-pitch))))
  (fixed-pitch ((t (:family ,my/font-family-fixed-pitch))))
  :config
  (add-hook 'after-make-frame-functions
            (lambda (frame)
              (with-selected-frame frame
                (my/prepend-emoji-font)))))

(use-package font-lock
  :config
  (custom-set-faces '(font-lock-string-face ((t (:slant italic))))))

;; Use ligatures, only prog-mode currently
(use-package ligature
  :ensure t
  :hook
  (after-init . global-ligature-mode)
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
(use-package markdown-ts-mode
  :mode
  ("\\.md\\'" . markdown-ts-mode))

(use-package nix-mode
  :ensure t)

(use-package face-remap
  :hook (org-mode . variable-pitch-mode))

(use-package imacs-org
  :ensure t)

(use-package rust-mode
  :ensure t
  :custom
  ;; Make rust use treesit
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
  (c-ts-indent-offset 4)
  ;; Doxygen integration is great
  (c-ts-mode-enable-doxygen t))

(use-package fennel-mode
  :ensure t
  :mode ("\\.fnl\\'" . fennel-mode))

(use-package just-ts-mode
  :ensure t)

(use-package elisp-mode
  :custom
  ;; Semantic fonitifcation is nice
  (elisp-fontify-semantically t))

(use-package java-ts-mode
  :custom
  (java-ts-mode-enable-doxygen t))

(use-package groovy-mode
  :ensure t)

(use-package elm-mode
  :ensure t)

(use-package coffee-mode
  :ensure t)

(use-package imacs-completion
  :ensure t)

(use-package eglot
  :defines eglot-mode-map)

(use-package elec-pair
  :functions electric-pair-default-inhibit
  :hook
  ;; Electric pair ootb [TODO] not in org?
  (after-init . electric-pair-mode)
  :custom
  (electric-pair-pairs
   '((34 . 34) ;; ""
     (91 . 93) ;; []
     (40 . 41) ;; ()
     ("\\/\\*" . " */"))))

(use-package avy
  :ensure t
  ;; Easy jump / yank
  :bind ("M-j" . avy-goto-char-timer))

;; Show documentation
(use-package eldoc-box
  :ensure t
  :after eglot
  :custom
  (alter-fullscreen-frames nil)
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

(defun my/kbaq-current-piece ()
  "Fetch the currently-playing music on KBAQ."
  (interactive)
  (url-retrieve
   (url-generic-parse-url "https://cadence.nprstations.org/api/cadence/widget/eeee8880-c130-4ec1-bec5-802797e5747e?show_song=true&format=json")
   (lambda (_)
     (goto-char url-http-end-of-headers)
     (let* ((json (json-parse-buffer :object-type 'plist))
            (song (plist-get json :currentlyPlayingSong))
            (title (plist-get song :title))
            (composer (plist-get song :composer)))
       (message "%s by %s" title composer)))))

(use-package emms
  :ensure t
  :bind
  ("C-x C-a p e" . emms)
  ("C-x C-a p p" . emms-start)
  ("C-x C-a p s" . emms-stop)
  ("C-x C-a p r" . my/radio-play)
  :custom
  ;; mpv backend for emms
  (emms-player-list '(emms-player-mpv))
  :config
  (require 'emms-setup)
  (emms-minimalistic))

(use-package material-icons
  :ensure t
  :hook
  (dired-mode . material-icons-dired-icons-mode)
  (ibuffer-mode . material-icons-ibuffer-icons-mode)
  :init
  (setq material-icons-size 22)
  (with-eval-after-load 'speedbar
    (material-icons-speedbar-icons-mode t)))

(use-package dired
  :functions
  dired-hide-details-mode
  dired-current-directory
  :custom
  ;; B/c Darwin is weird
  (dired-use-ls-dired (not (eq system-type 'darwin)))
  ;; Reduce columns
  (dired-hide-details-preserved-columns '(1 3 5 6 7 8))
  (dired-listing-switches "-alXh --group-directories-first")
  :hook
  (dired-mode . dired-hide-details-mode))

(use-package pdf-tools
  :ensure t
  :config
  ;; Compile in the pdf tools
  (pdf-tools-install nil t))
;; (use-package pdf-roll
;;   :hook pdf-view-mode)

;; Nicer looking org mode editing (centered column)
(use-package writeroom-mode
  :ensure t)

(use-package reader
  :ensure t)

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
  :hook
  ;; Save undo history
  (after-init . undo-fu-session-global-mode))

;; Ibuffer instead of whatever it was before
(use-package ibuffer
  :bind ("C-x C-b" . ibuffer)
  :hook
  (ibuffer-mode . ibuffer-auto-mode)
  :custom
  (ibuffer-show-empty-filter-groups nil))

;; Grouping ibuffer by project root
(use-package ibuffer-vc
  :ensure t
  :bind
  ( :map ibuffer-mode-map
    ("/ V" . ibuffer-vc-set-filter-groups-by-vc-root))
  :hook
  (ibuffer . (lambda () (ibuffer-vc-set-filter-groups-by-vc-root))))

(use-package delsel
  :hook
  ;; Delete selection when typing and region active
  (after-init . delete-selection-mode))

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

(use-package majutsu
  :ensure t)

(use-package diff-hl
  :ensure t
  :hook
  (after-init . global-diff-hl-mode)
  (after-init . diff-hl-margin-mode))

(use-package recentf
  :hook
  ;; Keep track of recently visited files
  (after-init . recentf-mode)
  :custom
  ;; Increase the limit
  (recentf-max-saved-items 200)
  :bind ("C-x C-r" . recentf))

(use-package saveplace
  :hook
  ;; Remember where last in file on reopen
  (after-init . save-place-mode)
  :custom
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
  :hook
  (after-init . global-treesit-fold-mode)
  ;; With the indicators, nice
  (after-init . global-treesit-fold-indicators-mode))

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
  (show-paren-context-when-offscreen 'overlay)
  (show-paren-not-in-comments-or-strings 'on-mismatch))

(use-package mwheel
  :custom
  ;; Mouse improvements
  (mouse-wheel-tilt-scroll t)
  (mouse-wheel-flip-direction t))

;; Use editorconfig
(use-package editorconfig
  :hook
  (after-init . editorconfig-mode))

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
  :hook
  (after-init . minibuffer-depth-indicate-mode))

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
    (setq cursor-type
          (if (and (boundp god-local-mode) god-local-mode)
              'box
            'bar)))
  :hook
  (post-command . my/update-cursor-type)
  (after-init . god-mode-all)
  :config
  (dolist (mode '(ghostel-mode speedbar-mode))
    (add-to-list 'god-exempt-major-modes mode)))

(use-package hl-line
  :hook
  (after-init . global-hl-line-mode))

(use-package s
  :functions s-trim)

(use-package autorevert
  :hook
  (after-init . global-auto-revert-mode))

(use-package apheleia
  :ensure t
  :hook
  (after-init . apheleia-global-mode))

(use-package help
  :custom
  (help-window-select t)
  (view-lossage-auto-refresh t))

(use-package devdocs
  :ensure t)

(use-package buffer-terminator
  :ensure t
  :hook
  (after-init . buffer-terminator-mode))

(use-package super-save
  :ensure t
  :hook (after-init . super-save-mode)
  :custom (super-save-auto-save-when-idle t))

;; Missing in the Elpa build smh
;; [TODO] enable once fixed (can't find symbol) currently
;;(use-package xref
;;  :hook
;;  (after-init . global-xref-mouse-mode))
(add-hook 'after-init (lambda () (global-xref-mouse-mode 1)))

(use-package system-taskbar
  :hook
  (after-init . system-taskbar-mode))

(use-package tty-tip
  :hook
  (after-init . tty-tip-mode))

;; [TODO] will I replace dired-sidebar with this?
(use-package speedbar
  :custom
  (speedbar-prefer-window t)
  (speedbar-show-unknown-files t)
  (speedbar-window-default-width 40)
  (speedbar-window-max-width 40)
  :bind
  ("C-x C-d" . speedbar)
  ( :map speedbar-file-key-map
    ("q" . speedbar)))

(defun my/discord-installed-p ()
  "Checks to see if a discord client is installed."
  (let ((packages-path "~/.config/home-manager/packages")
        (package-names '("discord" "vesktop" "equibop" "dissent" "dorion")))
    (when (file-exists-p packages-path)
      (and (any (lambda (prog) (seq-contains-p (json-read-file packages-path) prog (-flip #'s-contains-p))) package-names) t))))

(use-package elcord
  :ensure t
  :hook
  (after-init . (lambda () (when (my/discord-installed-p) (elcord-mode 1)))))

(use-package verb
  :ensure t)

(use-package tooltip
  :custom
  (tooltip-hide-delay 60))

(use-package eplot
  :ensure t)

(defvar my/emails-accounts-location
  "~/.config/sops-nix/secrets/emacs-emails.el")

(use-package minimail
  :ensure t
  :custom
  (mail-user-agent 'minimail)
  :config
  (load-file my/emails-accounts-location))

(defvar my/emacs-feeds-location
  "~/.config/sops-nix/secrets/emacs-feeds.el")

(use-package newsticker
  :custom
  (newsticker-url-list (my/user-secret-else my/emacs-feeds-location nil))
  (newsticker-url-list-defaults nil))

(use-package editorconfig
  :hook (after-init . editorconfig-mode))

(use-package pilish
  :ensure t
  :init
  (defalias 'pi 'pilish))

;; Direnv support
(use-package envrc
  :ensure t
  :after exec-path-from-shell
  ;; This needs to be hooked last to ensure it runs first
  :hook (after-init . envrc-global-mode)
  :functions envrc-propagate-environment envrc--find-env-dir
  :config
  ;; Advice a few poorly acting modes
  (dolist (fn '( Man-completion-table sql-sqlite ghostel-eshell--exec-visual))
    (advice-add fn :around #'envrc-propagate-environment)))

(provide 'init)
;;; init.el ends here
