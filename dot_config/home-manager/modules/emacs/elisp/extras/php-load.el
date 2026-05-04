;;; extras/php-load.el -*- lexical-binding: t; -*-

;;; Code:

(eval-when-compile
  (el-clone :repo "emacs-php/php-mode"))

(with-delayed-execution
 (message "Install php-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/php-mode/lisp"))

 (autoload-if-found '(php-mode php-current-class php-current-namespace) "php-mode" nil t)
 (autoload-if-found '(php-format-this-buffer-file
                      php-format-project
                      php-format-on-after-save-hook
                      php-format-auto-mode) "php-format" nil t)

 (add-to-list 'auto-mode-alist '("\\.php$" . php-mode))

 (with-eval-after-load 'php-mode
   ;; hook
   (add-hook 'php-mode-hook #'php-format-auto-mode)

   ;; keybind
   (define-key php-mode-map (kbd "C-c C--") #'php-current-class)
   (define-key php-mode-map (kbd "C-c C-=") #'php-current-namespace)
   (define-key php-mode-map (kbd "C-.") nil)

   ;; config
   (setopt php-mode-coding-style 'psr2)

   ;; phpstan
   (define-derived-mode phpstan-mode php-mode "phpstan")))

(eval-when-compile
  (el-clone :repo "emacs-php/php-ts-mode"))

(with-delayed-execution
 (message "Install php-ts-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/php-ts-mode"))
 (autoload-if-found '(php-ts-mode) "php-ts-mode" nil t)

 ;; (add-to-list 'auto-mode-alist '("\\.php$" . php-ts-mode))

 (with-eval-after-load 'php-ts-mode))
;; (add-hook 'php-ts-mode-hook #'eglot)

(eval-when-compile
  (el-clone :repo "emacs-php/phpt-mode"))

(with-delayed-execution
 (message "Install phpt-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/phpt-mode"))

 (autoload-if-found '(phpt-mode) "phpt-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.phpt$" . phpt-mode)))


(eval-when-compile
  (el-clone :repo "takeokunn/web-php-blade-mode"))

(with-delayed-execution
 (message "Install web-php-blade-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/web-php-blade-mode"))

 (autoload-if-found '(web-php-blade-mode) "web-php-blade-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.blade\\.php$" . web-php-blade-mode))

 ;; for php-mode
 (with-eval-after-load 'php-mode)
 ;; (add-hook 'php-mode-hook
 ;;           #'(lambda ()
 ;;               (key-combo-mode)
 ;;               (when (window-system)
 ;;                 (key-combo-define-local (kbd ",>") " => "))
 ;;               ;; (key-combo-define-local (kbd "+") '("+" " + " "++" " ++ "))
 ;;               ;; (key-combo-define-local (kbd "-") '("-" " - " "--" " -- "))
 ;;               ;; (key-combo-define-local (kbd "*") '("*" "**" " * "))
 ;;               ;; (key-combo-define-local (kbd "=") '("=" " = " "==" "==="))
 ;;               ))


 (with-eval-after-load 'lsp-mode)
 (add-to-list 'lsp-language-id-configuration '("php-ts-mode" . "php"))

 (with-eval-after-load 'lsp-php
   ;; for intelephense
   (setopt lsp-intelephense-telemetry-enabled t)
   (setopt lsp-intelephense-files-exclude ["**/.git/**" "**/.svn/**" "**/.hg/**" "**/CVS/**" "**/.DS_Store/**"
                                           "**/node_modules/**" "**/bower_components/**" "**/vendor/**/{Test,test,Tests,tests}/**"
                                           "**/.direnv/**"])))

(with-delayed-execution
 (message "Install lsp-php-key...")
 (with-eval-after-load 'lsp-php
   (setopt lsp-intelephense-licence-key "00OXTX8OROOJH9P"))
 (autoload-if-found '(dap-php-setup) "dap-php" nil t)

 (with-eval-after-load 'php-mode
   (add-hook 'php-mode-hook #'dap-php-setup))

 (with-eval-after-load 'dap-php
   ;; config
   (setopt dap-php-debug-path `,(expand-file-name "xdebug/vscode-php-debug" dap-utils-extension-path))

   ;; register
   (dap-register-debug-template "Laravel Run Configuration"
                                (list :type "php"
                                      :request "launch"
                                      :mode "remote"
                                      :host "localhost"
                                      :port 9003)))

 (with-eval-after-load 'lsp-bridge
   ;; config
   (setopt lsp-bridge-php-lsp-server "phpactor")))


(eval-when-compile
  (el-clone :repo "emacs-php/composer.el"))

(with-delayed-execution
 (message "Install composer...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/composer")))

(eval-when-compile
  (el-clone :repo "emacs-php/php-runtime.el"))

(with-delayed-execution
 (message "Install php-runtime...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/php-runtime"))

 (autoload-if-found '(php-runtime-expr php-runtime-eval) "php-runtime" nil t))

(eval-when-compile
  (el-clone :repo "emacs-php/psysh.el"))

(with-delayed-execution
 (message "Install psysh...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/psysh"))

 (autoload-if-found '(psysh psysh-doc) "psysh" nil t)

 (with-eval-after-load 'php-mode
   (define-key php-mode-map (kbd "C-c h") #'psysh-doc)))

(eval-when-compile
  (el-clone :repo "takeokunn/laravel-tinker-repl.el"))

(with-delayed-execution
 (message "Install laravel-tinker-repl...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/laravel-tinker-repl"))

 (autoload-if-found '(laravel-tinker-repl) "laravel-tinker-repl" nil t)

 (with-eval-after-load 'php-mode
   (define-key php-mode-map (kbd "C-c C-c") #'laravel-tinker-repl-send-line)
   (define-key php-mode-map (kbd "C-c C-z") #'laravel-tinker-repl-switch-to-repl)))

(eval-when-compile
  (el-clone :repo "moskalyovd/emacs-php-doc-block"))

(with-delayed-execution
 (message "Install emacs-php-doc-block...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-php-doc-block"))

 (autoload-if-found '(php-doc-block) "php-doc-block" nil t))

(eval-when-compile
  (el-clone :repo "emacs-php/phpstan.el"))

(with-delayed-execution
 (message "Install phpstan...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/phpstan"))

 (autoload-if-found '(phpstan-analyze-file phpstan-analyze-this-file) "phpstan" nil t)

 (defun my/flycheck-phpstan-setup ()
   "Setup Flycheck with PHPStan."
   (require 'flycheck-phpstan))

 (with-eval-after-load 'php-mode
   (add-hook 'php-mode-hook #'my/flycheck-phpstan-setup))

 (with-eval-after-load 'php-ts-mode
   (add-hook 'php-ts-mode-hook #'my/flycheck-phpstan-setup))

 (with-eval-after-load 'phpstan
   (setopt phpstan-memory-limit "4G")))

(eval-when-compile
  (el-clone :repo "nlamirault/phpunit.el"))

(with-delayed-execution
 (message "Install phpunit...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/phpunit"))

 (autoload-if-found '(phpunit-current-test
                      phpunit-current-class
                      phpunit-current-project
                      phpunit-group) "phpunit" nil t)



 (with-eval-after-load 'web-php-blade-mode
   (add-hook 'web-php-blade-mode #'emmet-mode)))

(when my/enable-org-load
  (eval-when-compile
    (el-clone :repo "Sasanidas/ob-php"))

  (with-delayed-execution
   (message "Install ob-php...")
   (add-to-list 'load-path (locate-user-emacs-file "el-clone/ob-php"))

   (autoload-if-found '(org-babel-execute:php) "ob-php" nil t)

   (with-eval-after-load 'org-src
     (add-to-list 'org-src-lang-modes '("php" . php))))

  (eval-when-compile
    (el-clone :repo "takeokunn/ob-phpstan"))

  (with-delayed-execution
   (message "Install ob-phpstan...")
   (add-to-list 'load-path (locate-user-emacs-file "el-clone/ob-phpstan"))

   (autoload-if-found '(org-babel-execute:phpstan) "ob-phpstan" nil t)

   (with-eval-after-load 'org-src
     (add-to-list 'org-src-lang-modes '("phpstan" . phpstan)))))


(provide 'php-load)
