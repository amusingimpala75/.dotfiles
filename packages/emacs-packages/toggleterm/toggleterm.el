;;; toggleterm.el -- Floating term, similar to toggleterm.nvim -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Luke Murray

;; Author: Luke Murray <69653100+amusingimpala75@users.noreply.github.com>
;; Keywords: terminal
;; Package-Version: 20250822
;; Package-Requires: ;; TODO

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the MIT License.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

;;; Commentary:

;; This package allows the easy toggle of a terminal for the given
;; buffer or project.

;;; Code:

(require 'project)

(defgroup toggleterm nil
  "Toggleable Terminal"
  :group 'external
  :prefix "toggleterm-")

(defcustom toggleterm-buffer-name "*toggleterm*"
  "Name of toggleterm buffers"
  :type 'string
  :group 'toggleterm)

(defcustom toggleterm-frame-name "ToggleTerm"
  "Name of toggleterm frame."
  :type 'string
  :group 'toggleterm)

(defcustom toggleterm-frame-padding 2
  "margin between edge of toggleterm and parent frame."
  :type 'integer
  :group 'toggleterm)

(defcustom toggleterm-frame-border-width 2
  "Width of child frame border."
  :type 'integer
  :group 'toggleterm)

(defcustom toggleterm-buffer-function #'toggleterm--start-eat
  "Function to call to create terminal buffer in current directory."
  :type 'symbol
  :group 'toggleterm)

(defvar toggleterm--frame nil
  "Frame for popping up as toggleterm.")

(defun toggleterm--start-eat ()
  (with-current-buffer (eat)
    (add-hook 'eat-exit-hook (lambda (proc) (kill-current-buffer)) nil t)
    (current-buffer)))

;; no need for toggleterm--start-eshell, #'eshell is good enough for customize

(defun toggleterm--get-frame ()
  "Get the toggleterm frame, creating if necessary."
  (if (and toggleterm--frame (frame-live-p toggleterm--frame) (equal (toggleterm--current-frame) (frame-parent toggleterm--frame)))
      toggleterm--frame
    (when (and toggleterm--frame (frame-live-p toggleterm--frame) (not (equal (toggleterm--current-frame) (frame-parent toggleterm--frame))))
      (delete-frame toggleterm--frame))
    (let* ((parent (toggleterm--current-frame)))
      (setq toggleterm--frame (make-frame `((name . ,toggleterm-frame-name)
                                            (parent-frame . ,parent)
                                            (undecorated . t)
                                            (child-frame-border-width . ,toggleterm-frame-border-width) ; TODO: fix in terminal
                                            (visibility . nil)))))))

(defun toggleterm--get-buffer-name (&optional directory)
  "Get the name for the toggleterm buffer for `directory'."
  (unless directory
    (setq directory default-directory))
  (format "%s<%s>" toggleterm-buffer-name directory))

(defun toggleterm--set-frame-parameters (frame &rest params)
  "Set the `params' for the frame.
`params' is list of cons cells."
  (dolist (cell params nil)
    (let ((attr (car cell))
          (val (cdr cell)))
      (set-frame-parameter frame attr val))))

(defun toggleterm--current-frame ()
  "Get the current frame."
  (window-frame (get-buffer-window (current-buffer))))

(defun toggleterm--hide-term ()
  "Hide the currently active toggleterm."
  (let ((frame (toggleterm--get-frame)))
    (delete-frame frame)
    (raise-frame (frame-parameter frame 'parent-frame))))

(defun toggleterm--show-term (buf)
  "Pop-up a toggleterm for `buf'."
  (if (not (string-prefix-p toggleterm-buffer-name (buffer-name buf)))
      (error "`buf' was not a toggleterm buffer"))
  (let* ((parent (toggleterm--current-frame))
         (frame (toggleterm--get-frame))
         (window (frame-root-window frame))
         (width (- (frame-width parent) (* 2 toggleterm-frame-padding)))
         (height (- (frame-height parent) (* 2 toggleterm-frame-padding)))
         (top (* toggleterm-frame-padding (frame-char-height)))
         (left (* toggleterm-frame-padding (frame-char-width))))
    (set-window-buffer window buf)
    (set-window-dedicated-p window t)
    (toggleterm--set-frame-parameters frame
                                      `(width . ,width)
                                      `(height . ,height)
                                      `(top . ,top)
                                      `(left . ,left)
                                      '(visibility . t))))

(defun toggleterm--start-term (&optional directory)
  "Start a toggleterm in `directory'.
assumed to be cwd if not provided."
  (unless directory
    (setq directory default-directory))
  (let* ((current-buffer (current-buffer))
         (current-window (get-buffer-window current-buffer))
         (default-directory directory))
    (with-current-buffer (apply toggleterm-buffer-function nil)
      (rename-buffer (toggleterm--get-buffer-name))
      (toggleterm--show-term (current-buffer)))
    (set-window-buffer current-window current-buffer)))

;;;###autoload
(defun toggleterm-toggle ()
  "Create or focus a toggleterm for the current file."
  (interactive)
  (let ((existing-buffer (get-buffer (toggleterm--get-buffer-name))))
    (cond ((string-prefix-p toggleterm-buffer-name (buffer-name))
           (toggleterm--hide-term))
          (existing-buffer (toggleterm--show-term existing-buffer))
          (t (toggleterm--start-term)))))

;;;###autoload
(defun toggleterm-toggle-project ()
  "Toggle for the current project."
  (interactive)
  (unless (project-current)
    (message "not currently in a project"))
  (when (project-current)
    (let* ((root (project-root (project-current)))
           (existing-buffer (get-buffer (toggleterm--get-buffer-name root))))
      (cond ((string-prefix-p toggleterm-buffer-name (buffer-name))
             (toggleterm--hide-term))
            (existing-buffer (toggleterm--show-term existing-buffer))
            (t (toggleterm--start-term root))))))

;;;###autoload
(defun toggleterm-dwim ()
  "Open toggleterm in project if in project, else in cwd."
  (interactive)
  (if (project-current)
      (toggleterm-toggle-project)
    (toggleterm-toggle)))

(provide 'toggleterm)
;;; toggleterm.el ends here
