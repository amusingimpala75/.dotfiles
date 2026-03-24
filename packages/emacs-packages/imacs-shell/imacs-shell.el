;;; imacs-shell.el --- Shell and Term configuration -*- lexical-binding: t -*-

;; Author: amusingimpala75
;; Maintainer: amusingimpala75
;; Version: 0.1.0
;; Package-Requires:
;; Homepage:
;; Keywords:

;;; Commentary:

;;; Code:

;; I don't need both of these, I'm probably
;; going to get rid of eat at some point
(use-package eat :ensure t)
(use-package vterm :ensure t)

;; [TODO] this needs to be fixed to use eshell
(use-package toggleterm
  :defer nil
  :ensure t
  :bind ("C-x C-a t" . toggleterm-dwim))

;; Eshell is a great general shell with the caveat
;; of using vterm for visual stuff.
(use-package eshell
  :defer 5
  :custom
  ;; Regexp for prompt, ending with λ
  (eshell-prompt-regexp "^[^#$\n]* [λ#] ")
  ;; Disable prompt highlighting
  (eshell-highlight-prompt nil)
  ;; Use my custom prompt
  (eshell-prompt-function 'my/eshell-prompt)
  ;; Alias clear actually clear the screen
  ;; rather than just filling it with newlines
  (eshell-command-aliases-list '(("clear" "clear t")))
  ;; Don't ask to define aliases for mistypes commands
  (eshell-bad-command-tolerance most-positive-fixnum)
  :functions
  eshell/cd
  eshell/echo
  :preface
  ;; Zoxide integration. [TODO] does it
  ;; update zoxide as well, or just query it?
  (defun eshell/z (&rest args)
    "Jump to directory using zoxide."
    (let* ((args-string
            (mapconcat
             (lambda (x)
               (if (numberp x)
                   (number-to-string x)
                 x))
             args " "))
           (cmd (concat "zoxide query -- " args-string))
           (results
            (with-temp-buffer
              (list :exit-code (call-process-shell-command cmd nil t)
                    :target (string-trim (buffer-string)))))
           (exit-code (plist-get results :exit-code))
           (target (plist-get results :target)))
      (if (not (= 0 exit-code))
          (eshell/echo "zoxide: no match found")
        (eshell/cd target))))
  (defun my/eshell-prompt ()
    "Generate my eshell prompt."
    (propertize
     (concat
      (propertize
       (user-login-name)
       'face 'font-lock-type-face)
      "@"
      (propertize
       (my/smart-hostname) 'face '(font-lock-keyword-face :underline t))
      " "
      (when (project-current)
        (concat
         (propertize
          (file-name-base
           (directory-file-name (project-root (project-current))))
          'face 'font-lock-string-face)
         "#"))
      (propertize
       (file-name-base
        (directory-file-name (abbreviate-file-name default-directory)))
       'face 'font-lock-string-face)
      (propertize
       (if (envrc--find-env-dir) " (direnv)" "")
       'face 'font-lock-comment-face)
      (propertize
       (if (not (= 0 eshell-last-command-status))" :(" "") 'face 'error)
      " λ "
      )
     'read-only t
     'front-sticky '(font-lock-face read-only)
     'rear-nonsticky '(font-lock-face read-only)))
  (defun my/smart-hostname ()
    "Get the hostname of the system.

Normal for NixOS, but it will use a different
method on darwin since we don't need the
extra junk that it provides otherwise"
    (if (eq system-type 'darwin)
        (s-trim (shell-command-to-string "scutil --get LocalHostName"))
      (system-name)))
  :config
  ;; Add the list of visual commands / subcommands / options
  (dolist (command '("pi" "piw" "nh" "gradlew" "dx" "ssh"))
    (add-to-list 'eshell-visual-commands command))
  (dolist (subcommands '(("jj" "diff" "squash" "log")))
    (add-to-list 'eshell-visual-subcommands subcommands))
  (dolist (options '(("jj" "--editor" "--help")))
    (add-to-list 'eshell-visual-options options))
  ;; Make sure programs know we can handle colors
  (setenv "TERM" "xterm-256color"))

(use-package esh-mode
  :defines eshell-preoutput-filter-functions
  :config
  (add-to-list 'eshell-preoutput-filter-functions 'xterm-color-filter))

(use-package xterm-color
  :ensure t
  :custom (xterm-color-preserve-properties t))

(use-package eshell-vterm
  :ensure t
  :custom (eshell-vterm-mode t))

(provide 'imacs-shell)

;;; imacs-shell.el ends here
