;;; imacs-completion.el --- Completion configuration -*- lexical-binding: t -*-

;; Author: amusingimpala75
;; Maintainer: amusingimpala75
;; Version: 0.1
;; Package-Requires:
;; Homepage:
;; Keywords:

;;; Commentary:

;;; Code:

;; Eglot used for LSP
(use-package eglot
  :defer t
  :functions eglot-completion-at-point
  :bind
  ( :map eglot-mode-map
    ("C-c l a" . eglot-code-actions)
    ("C-c l h" . eglot-inlay-hints-mode)
    ("C-c l f" . eglot-format)
    ("C-c l r" . eglot-rename))
  :custom
  ;; This fixes some weird line height changes on Darwin
  (eglot-code-action-indicator "")
  ;; Enable semantic tokens
  (eglot-semantic-tokens-mode t)
  ;; Better performance supposedly
  (eglot-stay-out-of '(imenu))
  ;; Clean up last eglot buffer
  (eglot-autoshutdown t)
  :hook
  ;; Hook into a variety of prog modes
  (( c-ts-mode bash-ts-mode fennel-mode go-ts-mode haskell-mode
     nix-mode java-ts-mode js-ts-mode typescript-ts-mode
     lua-ts-mode rustic-mode scala-mode)
   . eglot-ensure)
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

;; Snippets completion
(use-package yasnippet
  :ensure t
  :custom
  (yas-global-mode t))
;; Use pre-packaged snippets
(use-package yasnippet-snippets
  :ensure t
  :functions
  yas-reload-all
  :config
  (yas-reload-all))
;; Make sure there's a capf available
(use-package yasnippet-capf
  :ensure t)

;; Use icomplete for minibuffer completion
;; Currently as a replacement for Vertico, we'll
;; see if I end up missing anything
(use-package icomplete
  :bind
  ( :map icomplete-minibuffer-map
    ("C-n" . icomplete-forward-completions)
    ("C-p" . icomplete-backward-completions)
    ("TAB" . icomplete-force-complete)
    ("RET" . icomplete-force-complete-and-exit)
    ("C-v" . icomplete-vertical-mode)
    ("SPC" . self-insert-command))
  :custom
  ;; Show icomplete vertically
  (icomplete-vertical-mode t)
  ;; Scroll
  (icomplete-scroll t)
  ;; Show before typing anything
  (icomplete-show-matches-on-no-input t)
  ;; Don't bother waiting, immediately run
  (icomplete-max-delay-chars 0)
  (icomplete-compute-delay 0)
  ;; Show prefix
  (icomplete-vertical-render-prefix-indicator t)
  ;; Don't modify entries
  (icomplete-hide-common-prefix nil)
  :hook
  ;; Truncate lines, else marginalia breaks stuff
  (icomplete-minibuffer-setup . (lambda () (setq truncate-lines t))))

;; Show useful information like the docstring in completions
(use-package marginalia
  :ensure t
  :custom
  (marginalia-mode 1)
  :bind
  ( :map minibuffer-local-map
    ("M-a" . marginalia-cycle)))

;; [TODO] could I get away with flex?
(use-package orderless
  :ensure t
  :custom
  ;; Use the orderless completion
  (completion-styles '(orderless basic))
  (completion-category-overrides
   '((file (styles basic partial-completion))
     (command (styles orderless basic))
     (function (styles orderless basic))
     (variable (styles orderless basic)))))

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

;; Be able to do stuff extra (mostly use with wgrep)
(use-package embark
  :ensure t
  :bind
  ("C-c k a" . embark-act)
  ("C-c k e" . embark-export))
(use-package embark-consult
  :ensure t)

;; Writable grep: write changes back into fs
(use-package wgrep
  :ensure t)

(use-package pcomplete
  :functions pcomplete-completions-at-point)

;; Combine capfs
(use-package cape
  :ensure t
  :init
  ;; Define super capfs for various modes
  (defvar my/eglot-capf
    (cape-capf-super
     #'yasnippet-capf #'eglot-completion-at-point #'cape-abbrev))
  (defvar my/elisp-capf
    (cape-capf-super
     #'yasnippet-capf #'cape-abbrev #'cape-dabbrev #'elisp-completion-at-point))
  (defvar my/org-capf
    (cape-capf-super
     #'yasnippet-capf #'cape-abbrev #'cape-elisp-block))
  (defvar my/generic-capf
    (cape-capf-super #'yasnippet-capf #'cape-abbrev))
  (defvar my/eshell-capf
    (cape-capf-super
     #'yasnippet-capf #'pcomplete-completions-at-point #'cape-history))

  (defun my/cape-capf-set ()
    "Setup capfs depending on the mode."
    (interactive)
    (setq-local
     completion-at-point-functions
     (list
      #'cape-file
      (cond ((equal major-mode #'org-mode)
             my/org-capf)
            ((equal major-mode #'eshell-mode)
             my/eshell-capf)
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
  :hook
  (after-init . global-corfu-mode))

(use-package corfu-popupinfo
  :after corfup
  :custom
  ;; Popup the documentation after half a second [TODO] reduce?
  (corfu-popupinfo-delay '(0.25 . 0.25))
  :hook corfu-mode)

;; [TODO] fix suggestion in org mode at least not being
;;        anything other than a simple dict autocomplete (abbrev not showing?)
(use-package completion-preview
  :hook
  (after-init . global-completion-preview-mode)
  ;; Show after two chars
  :custom (completion-preview-minimum-symbol-length 2)
  :config
  ;; Allow org movement commands to still trigger completion
  (setq completion-preview-commands
        (append completion-preview-commands
                '(org-self-insert-command org-delete-backward-char))))

(provide 'imacs-completion)

;;; imacs-completion.el ends here
