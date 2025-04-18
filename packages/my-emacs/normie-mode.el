;;; -*- lexical-binding: t -*-

(defvar normie-mode--isearch-wrap-pause-backup nil)

(define-minor-mode normie-mode
  "Toggles global normie-mode (supposedly normal keybinds)"
  nil ; disabled by default
  :global t
  :group 'my
  :lighter " normie"
  :keymap
  `((,(kbd "C-q") . save-buffers-kill-terminal)
    (,(kbd "C-w") . delete-window)
    ;; C-e
    (,(kbd "C-r") . query-replace)
    ;; C-t
    ;; C-y
    ;; C-u
    ;; C-i
    (,(kbd "C-o") . find-file)
    ;; C-p
    (,(kbd "C-a") . mark-whole-buffer)
    (,(kbd "C-s") . save-buffer)
    ;; C-d
    (,(kbd "C-f") . isearch-forward) ;; Needs more work with wrapping
    ;; C-g
    ;; C-h
    ;; C-j
    ;; C-k
    ;; C-l
    (,(kbd "C-z") . undo)
    (,(kbd "C-Z") . undo-redo)
    (,(kbd "C-x") . kill-region)
    (,(kbd "C-c") . kill-ring-save)
    (,(kbd "C-v") . yank)
    ;; C-b
    ;; C-n
    ;; C-m
    )
  (if normie-mode
      (setq normie-mode--isearch-wrap-pause-backup isearch-wrap-pause
            isearch-wrap-pause nil)
    (setq isearch-wrap-pause normie-mode--isearch-wrap-pause-backup)))

(provide 'normie-mode)
