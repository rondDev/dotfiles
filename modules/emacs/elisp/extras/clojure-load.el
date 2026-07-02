;;; extras/clojure-load.el -*- lexical-binding: t; -*-

;;; Code:


(eval-when-compile
  (el-clone :repo "clojure-emacs/clojure-mode"))

(with-delayed-execution
 (message "Install clojure-mode")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/clojure-mode"))

 (autoload-if-found '(clojure-mode clojurescript-mode) "clojure-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.clj$" . clojure-mode))
 (add-to-list 'auto-mode-alist '("\\.cljs$" . clojurescript-mode))

 (with-eval-after-load 'clojure-mode
   ;; config
   (setopt clojure-toplevel-inside-comment-form t)

   ;; keybind
   (define-key clojure-mode-map (kbd "C-:") #'avy-goto-word-1)))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '(clojure-mode clojurescript-mode clojurec-mode
                                                     . ("/Users/take/.emacs.d/.cache/lsp/clojure/clojure-lsp"
                                                        "listen" "--verbose")))) 



(eval-when-compile
  (el-clone :repo "clojure-emacs/parseclj")
  (el-clone :repo "clojure-emacs/parseedn")
  (el-clone :repo "clojure-emacs/cider"))

(with-delayed-execution
 (message "Install cider...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/parseclj"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/parseedn"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/cider"))

 (autoload-if-found '(cider cider-format-buffer cider-switch-to-last-clojure-buffer) "cider" nil t)
 (autoload-if-found '(cider-doc) "cider-doc" nil t)

 ;; (add-hook 'before-save-hook #'cider-format-buffer t t)

 (with-eval-after-load 'cider-common
   (setopt cider-special-mode-truncate-lines nil))

 (with-eval-after-load 'cider-mode
   (setopt cider-font-lock-reader-conditionals nil)
   (setopt cider-font-lock-dynamically '(macro core function var)))

 (with-eval-after-load 'cider-repl
   (setopt cider-repl-buffer-size-limit 1000000)
   (setopt cider-repl-wrap-history t)
   (setopt cider-repl-history-size 10000)
   (setopt cider-repl-tab-command #'indent-for-tab-command)
   (setopt cider-repl-display-in-current-window t))

 (with-eval-after-load 'nrepl-client
   (setopt nrepl-use-ssh-fallback-for-remote-hosts t)
   (setopt nrepl-hide-special-buffers t))

 (with-eval-after-load 'cider-eval
   (setopt cider-show-error-buffer nil)
   (setopt cider-auto-select-error-buffer nil))

 (with-eval-after-load 'clojure-mode
   (define-key clojure-mode-map (kbd "C-c h") #'cider-doc)))

(eval-when-compile
  (el-clone :repo "clojure-emacs/clj-refactor.el"))

(with-delayed-execution
 (message "Install clj-refactor...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/clj-refactor")))

;; (autoload-if-found '(clj-refactor-mode cljr-add-keybindings-with-prefix) "clj-refactor" nil t)

;; (add-hook 'clojure-mode-hook #'clj-refactor-mode)
;; (cljr-add-keybindings-with-prefix "C-c C-m")

;; (with-eval-after-load 'clj-refactor
;;   (setopt cljr-suppress-middleware-warnings t)
;;   (setopt cljr-hotload-dependencies t))

(eval-when-compile
  (el-clone :repo "clojure-emacs/inf-clojure"))

(with-delayed-execution
 (message "Install inf-clojure...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/inf-clojure"))

 (autoload-if-found '(inf-clojure) "inf-clojure" nil t))


(with-delayed-execution
 (message "Install phel-mode...")

 (define-derived-mode phel-mode clojure-mode "Phel"
   "Major mode for editing Phel language source files."
   (setopt-local comment-start "#")
   ;; We disable lockfiles so that ILT evaluation works.
   ;; The lockfiles seem to modify the buffer-file-name somehow, when the buffer changes
   ;; And that is detected by the currently running Phel process.
   ;; That interferes with evaluation, as the running Phel process starts behaving badly because of that.
   (setopt-local create-lockfiles nil))
 

 (add-to-list 'auto-mode-alist '("\\.phel$" . phel-mode)))

(provide 'clojure-load)
