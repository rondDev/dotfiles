;;; extras/exwm.el -*- lexical-binding: t; -*-

;;; Code:
(eval-when-compile
  (el-clone :repo "ch11ng/exwm"))

(eval-when-compile
  (el-clone :repo "agzam/exwm-edit"))

;; (when (string= system-type "gnu/linux")
;;   (with-delayed-execution
;;     (message "Install exwm-edit...")
;;     (add-to-list 'load-path (locate-user-emacs-file "el-clone/exwm-edit"))

;;     (autoload-if-found '(exwm-edit--compose-minibuffer) "exwm-edit" nil t)

;;     (exwm-input-set-key (kbd "C-c '") #'exwm-edit--compose-minibuffer)
;;     (exwm-input-set-key (kbd "C-c C-'") #'exwm-edit--compose-minibuffer)

;;     (with-eval-after-load 'exwm-edit
;;       (setopt exwm-edit-bind-default-keys nil))))

(eval-when-compile
  (el-clone :repo "SqrtMinusOne/exwm-modeline"))

;; (when (string= system-type "gnu/linux")
;;   (with-delayed-execution
;;     (message "Install exwm-modeline...")
;;     (add-to-list 'load-path (locate-user-emacs-file "el-clone/exwm-modeline"))

;;     (autoload-if-found '(exwm-modeline-mode) "exwm-modeline")

;;     (with-eval-after-load 'exwm-core
;;       (add-hook 'exwm-mode-hook #'exwm-modeline-mode))

;;     (with-eval-after-load 'exwm-modeline
;;       (setopt exwm-modeline-short t))))
(provide 'exwm-load)
