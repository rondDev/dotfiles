;;; init.el -*- lexical-binding: t; -*-
;;; Rewrite is based on: https://github.com/takeokunn/.emacs.d
;;; With code taken from my own: https://github.com/girlkissers/gkmacs

(defconst my/enable-clojure-load t
  "If non-nil, load clojure.")

(defconst my/enable-org-load t
  "If non-nil, load org.")

(defconst my/enable-php-load nil
  "If non-nil, load php.")

(defconst my/loading-profile-p nil
  "If non-nil, use built-in profiler.el.")

(defconst my/enable-profile nil
  "If true, enable profile")

(defmacro when-darwin (&rest body)
  (when (string= system-type "darwin")
    `(progn ,@body)))

(defmacro when-darwin-not-window-system (&rest body)
  (when (and (string= system-type "darwin")
             window-system)
    `(progn ,@body)))

(defmacro when-guix (&rest body)
  (when (string= system-type "guix")
    `(progn ,@body)))

(setq user-full-name "rondDev")
(setq user-mail-address "contact@rond.cc")

(when my/enable-profile
  (require 'profiler)
  (profiler-start 'cpu))

(defconst my/saved-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(defconst my/before-load-init-time (current-time))

;;;###autoload
(defun my/load-init-time ()
  "Loading time of user init files including time for `after-init-hook'."
  (let ((time1 (float-time
                (time-subtract after-init-time my/before-load-init-time)))
        (time2 (float-time
                (time-subtract (current-time) my/before-load-init-time))))
    (message (concat "Loading init files: %.0f [msec], "
                     "of which %.f [msec] for `after-init-hook'.")
             (* 1000 time1) (* 1000 (- time2 time1)))))
(add-hook 'after-init-hook #'my/load-init-time t)

(defvar my/tick-previous-time my/before-load-init-time)

;;;###autoload
(defun my/tick-init-time (msg)
  "Tick boot sequence at loading MSG."
  (when my/loading-profile-p
    (let ((ctime (current-time)))
      (message "---- %5.2f[ms] %s"
               (* 1000 (float-time
                        (time-subtract ctime my/tick-previous-time)))
               msg)
      (setq my/tick-previous-time ctime))))

(defun my/emacs-init-time ()
  "Emacs booting time in msec."
  (interactive)
  (message "Emacs booting time: %.0f [msec] = `emacs-init-time'."
           (* 1000
              (float-time (time-subtract
                           after-init-time
                           before-init-time)))))

(add-hook 'after-init-hook #'my/emacs-init-time)

(defmacro my/with-timer (name &rest body)
  `(let ((time (current-time)))
     ,@body
     (message "%s: %.06f" ,name (float-time (time-since time)))))

(defvar my/delayed-priority-high-configurations '())
(defvar my/delayed-priority-high-configuration-timer nil)

(defvar my/delayed-priority-low-configurations '())
(defvar my/delayed-priority-low-configuration-timer nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq my/delayed-priority-high-configuration-timer
                  (run-with-timer
                   0.1 0.001
                   (lambda ()
                     (if my/delayed-priority-high-configurations
                         (let ((inhibit-message t))
                           (eval (pop my/delayed-priority-high-configurations)))
                       (progn
                         (cancel-timer my/delayed-priority-high-configuration-timer))))))
            (setq my/delayed-priority-low-configuration-timer
                  (run-with-timer
                   0.3 0.001
                   (lambda ()
                     (if my/delayed-priority-low-configurations
                         (let ((inhibit-message t))
                           (eval (pop my/delayed-priority-low-configurations)))
                       (progn
                         (cancel-timer my/delayed-priority-low-configuration-timer))))))))

(defmacro with-delayed-execution-priority-high (&rest body)
  (declare (indent 0))
  `(setq my/delayed-priority-high-configurations
         (append my/delayed-priority-high-configurations ',body)))

(defmacro with-delayed-execution (&rest body)
  (declare (indent 0))
  `(setq my/delayed-priority-low-configurations
         (append my/delayed-priority-low-configurations ',body)))

()

;;;###autoload
(defun autoload-if-found (functions file &optional docstring interactive type)
  "set autoload iff. FILE has found."
  (when (locate-library file)
    (dolist (f functions)
      (autoload f file docstring interactive type))
    t))

(eval-and-compile
  (setq byte-compile-warnings '(cl-functions))
  (require 'cl-lib nil t))

(with-delayed-execution-priority-high
 (message "Install cl-lib...")
 (require 'cl-lib))

(eval-when-compile
  (unless (file-directory-p (locate-user-emacs-file "elpa/el-clone"))
    (package-vc-install "https://github.com/takeokunn/el-clone.git")))

(eval-and-compile
  (add-to-list 'load-path (locate-user-emacs-file "elpa/el-clone"))
  (require 'el-clone))

(require 'flymake)
(require 'flymake-proc)

(with-delayed-execution
 (message "Install disable-show-trailing-whitespace...")

 (defun my/disable-show-trailing-whitespace ()
   (setq show-trailing-whitespace nil))

 (with-eval-after-load 'minibuffer
   (add-hook 'minibuffer-inactive-mode-hook #'my/disable-show-trailing-whitespace))

 (with-eval-after-load 'dashboard
   (add-hook 'dashboard-mode-hook #'my/disable-show-trailing-whitespace))

 (with-eval-after-load 'simple
   (add-hook 'fundamental-mode-hook #'my/disable-show-trailing-whitespace)))

(with-delayed-execution
 (message "Install display-line-numbers...")
 (autoload-if-found '(global-display-line-numbers-mode) "display-line-numbers" nil t)
 (global-display-line-numbers-mode)
 (menu-bar--display-line-numbers-mode-relative)


 (with-eval-after-load 'display-line-numbers
   (setq display-line-numbers-grow-only t)))

(with-eval-after-load 'simple
  (setq kill-whole-line t))

(with-delayed-execution
 (message "Install show-paren-mode...")
 (show-paren-mode t)

 (with-eval-after-load 'paren
   (setq show-paren-style 'mixed)))

(with-delayed-execution
 (message "Install electric-pair-mode...")
 (electric-pair-mode 1))

;; language and locale
(setq system-time-locale "C")

;; coding system
(set-default-coding-systems 'utf-8-unix)
(prefer-coding-system 'utf-8-unix)
(set-selection-coding-system 'utf-8-unix)

;; prefer-coding-system take effect equally to follows
(set-buffer-file-coding-system 'utf-8-unix)
(set-file-name-coding-system 'utf-8-unix)
(set-terminal-coding-system 'utf-8-unix)
(set-keyboard-coding-system 'utf-8-unix)
(setq locale-coding-system 'utf-8-unix)

(with-delayed-execution
 (message "Install global-auto-revert-mode...")
 (global-auto-revert-mode t))

(with-delayed-execution
 (fset 'yes-or-no-p 'y-or-n-p))



(with-delayed-execution-priority-high
 (message "Install savehist...")
 (savehist-mode 1))

(with-delayed-execution
 (defun my/copy-from-osx ()
   (shell-command-to-string "pbpaste"))

 (defun my/paste-to-osx (text)
   (let ((process-connection-type nil))
     (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
       (process-send-string proc text)
       (process-send-eof proc))))

 (when-darwin-not-window-system
  (setq interprogram-cut-function #'my/paste-to-osx)
  (setq interprogram-paste-function #'my/copy-from-osx)))

(with-eval-after-load 'comp
  (setq native-comp-async-jobs-number 8)
  (setq native-comp-speed 2)
  (setq native-comp-always-compile t)

  (defun my/native-comp-packages ()
    (interactive)
    (native-compile-async "~/.config/emacs.nix/init.el")
    (native-compile-async "~/.config/emacs.nix/early-init.el")
    (native-compile-async "~/.config/emacs.nix/el-clone" 'recursively)
    (native-compile-async "~/.config/emacs.nix/elpa" 'recursively)))

(with-eval-after-load 'comp
  (setq package-native-compile nil))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(consult el-clone embark magit org-modern popper rainbow-mode
             spacious-padding))
 '(package-vc-selected-packages
   '((el-clone :vc-backend Git :url
               "https://github.com/takeokunn/el-clone.git")))
 '(warning-suppress-types '((comp))))

(with-eval-after-load 'uniquify
  (setq uniquify-buffer-name-style 'post-forward-angle-brackets))

(with-current-buffer "*scratch*"
  (emacs-lock-mode 'kill))

(with-current-buffer "*Messages*"
  (emacs-lock-mode 'kill))

(with-eval-after-load 'time
  (setq display-time-24hr-format t)
  (setq display-time-day-and-date t))

(setq warning-minimum-level :error)


(setq echo-keystrokes 0.1)

(setq enable-recursive-minibuffers t)

(setq inhibit-compacting-font-caches t)

(with-delayed-execution
 (save-place-mode 1))

(setq enable-local-variables :all)

(with-eval-after-load 'password-cache
  (setq password-cache t)
  (setq password-cache-expiry 3600))

(setq tab-width 2)

(setq-default indent-tabs-mode nil)

(setq read-file-name-completion-ignore-case t)
(setq read-buffer-completion-ignore-case t)
(setq completion-ignore-case t)

;; Emacs Lisp functions for dealing with associative structures in a uniform and functional way.
(eval-when-compile
  (el-clone :repo "plexus/a.el"))

(with-delayed-execution-priority-high
 (message "Install a...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/a")))

;;  A Growl-like alerts notifier for Emacs 
(eval-when-compile
  (el-clone :repo "jwiegley/alert"))

(with-delayed-execution-priority-high
 (message "Install alert...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/alert")))

;; Module for doing asynchronous processing in Emacs
(eval-when-compile
  (el-clone :repo "jwiegley/emacs-async"))

(with-delayed-execution-priority-high
 (message "Install async...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-async")))

(eval-when-compile
  (el-clone :repo "protesilaos/pulsar"))

(with-delayed-execution
 (message "Install pulsar")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/pulsar"))

 (autoload-if-found '(pulsar-global-mode) "pulsar" nil t)
 (pulsar-global-mode 1))

(eval-when-compile
  (el-clone :repo "emacs-evil/evil"))

(with-delayed-execution-priority-high
 (message "Install evil")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/evil"))

 (autoload-if-found '(evil-mode) "evil" nil t)
 (evil-mode 1))

(with-eval-after-load 'evil
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (setq evil-undo-system 'undo-fu)

  (setq evil-kill-on-visual-paste nil))

(eval-when-compile
  (el-clone :repo "emacs-evil/evil-collection"))

(with-delayed-execution-priority-high
 (message "Install evil-collection")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/evil-collection"))

 (autoload-if-found '(evil-collection) "evil-collection" nil t))


(with-eval-after-load 'evil-collection
  (evil-collection-init)
  (evil-collection-ibuffer-setup))

;; A modern list library for Emacs 
(eval-when-compile
  (el-clone :repo "magnars/dash.el"))

(with-delayed-execution-priority-high
 (message "Install dash...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/dash")))

;; el-patch provides a way to customize the behavior of Emacs Lisp functions that do not provide enough variables and hooks to let you make them do what you want
(eval-when-compile
  (el-clone :repo "radian-software/el-patch"))

(with-delayed-execution
 (message "Install el-patch...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/el-patch")))

;; EmacSQL is a high-level Emacs Lisp front-end for SQLite.
(eval-when-compile
  (el-clone :repo "magit/emacsql"))

(with-delayed-execution-priority-high
 (message "Install emacsql...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacsql")))

;; Modern API for working with files and directories in Emacs 
(eval-when-compile
  (el-clone :repo "rejeep/f.el"))

(with-delayed-execution-priority-high
 (message "Install f...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/f")))

;; Access variables local to a frame 
(eval-when-compile
  (el-clone :repo "sebastiencs/frame-local"))

(with-delayed-execution-priority-high
 (message "Install frame-local...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/frame-local")))

;; Human-friendly alternative to HSL
(eval-when-compile
  (el-clone :repo "hsluv/hsluv-emacs"))

(with-delayed-execution-priority-high
 (message "Install hsluv-emacs...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/hsluv-emacs")))

;; The missing hash table library for Emacs
(eval-when-compile
  (el-clone :repo "Wilfred/ht.el"))

(with-delayed-execution-priority-high
 (message "Install ht...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ht")))

;; This is a package for GNU Emacs that can be used to tie related commands into a family of short bindings with a common prefix - a Hydra.
(eval-when-compile
  (el-clone :repo "abo-abo/hydra"))

(with-delayed-execution-priority-high
 (message "Install hydra...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/hydra")))

;; Edit multiple occurrences in the same way simultaneously
(eval-when-compile
  (el-clone :repo "victorhge/iedit"))

(with-delayed-execution-priority-high
 (message "Install iedit...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/iedit")))

;; elisp utility for defining functions which contextually jump between files 
(eval-when-compile
  (el-clone :repo "eschulte/jump.el"))

(with-delayed-execution-priority-high
 (message "Install jump...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/jump")))

;; Pentadactyl-like Link Hinting in Emacs with Avy 

(eval-when-compile
  (el-clone :repo "noctuid/link-hint.el"))

(with-delayed-execution
 (message "Install link-hint...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/link-hint")))

(eval-when-compile
  (el-clone :repo "rolandwalker/list-utils"))

(with-delayed-execution-priority-high
 (message "Install list-utils...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/list-utils")))

(eval-when-compile
  (el-clone :repo "aki2o/log4e"))

(with-delayed-execution
 (message "Install log4e...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/log4e")))

(eval-when-compile
  (el-clone :repo "sigma/marshal.el"))

(with-delayed-execution-priority-high
 (message "Install marshal...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/marshal")))

(eval-when-compile
  (el-clone :repo "sigma/mocker.el"))

(with-delayed-execution-priority-high
 (message "Install mocker...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/mocker")))

(eval-when-compile
  (el-clone :repo "Wilfred/mustache.el"))

(with-delayed-execution-priority-high
 (message "Install mustache...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/mustache")))

(eval-when-compile
  (el-clone :repo "emacsorphanage/ov"))

(with-delayed-execution-priority-high
 (message "Install ov...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ov")))

(eval-when-compile
  (el-clone :repo "purcell/page-break-lines"))

(with-delayed-execution
 (message "Install page-break-lines")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/page-break-lines"))
 (global-page-break-lines-mode))

(eval-when-compile
  (el-clone :repo "emacsmirror/persist"))

(with-delayed-execution
 (message "Install persist...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/persist")))

(eval-when-compile
  (el-clone :repo "Alexander-Miller/pfuture"))

(with-delayed-execution-priority-high
 (message "Install pfuture...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/pfuture")))

(eval-when-compile
  (el-clone :repo "emacsorphanage/pkg-info"))

(with-delayed-execution-priority-high
 (message "Install pkg-info...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/pkg-info")))

(eval-when-compile
  (el-clone :repo "alphapapa/plz.el"))

(with-delayed-execution-priority-high
 (message "Install plz...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/plz")))

(eval-when-compile
  (el-clone :repo "tumashu/posframe"))

(with-delayed-execution-priority-high
 (message "Install posframe...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/posframe")))

(eval-when-compile
  (el-clone :repo "auto-complete/popup-el"))

(with-delayed-execution-priority-high
 (message "Install popup-el...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/popup-el")))

(eval-when-compile
  (el-clone :repo "milkypostman/powerline"))

(with-delayed-execution-priority-high
 (message "Install powerline...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/powerline")))

(eval-when-compile
  (el-clone :repo "emacsmirror/queue"))

(with-delayed-execution-priority-high
 (message "Install queue...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/queue")))

(eval-when-compile
  (el-clone :repo "nlamirault/ripgrep.el"))

(with-delayed-execution
 (message "Install ripgrep...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ripgrep")))

(eval-when-compile
  (el-clone :repo "purcell/emacs-reformatter"))

(with-delayed-execution-priority-high
 (message "Install emacs-reformatter...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-reformatter")))

(eval-when-compile
  (el-clone :repo "tkf/emacs-request"))

(with-delayed-execution-priority-high
 (message "Install emacs-request...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-request")))

(eval-when-compile
  (el-clone :repo "magnars/s.el"))

(with-delayed-execution-priority-high
 (message "Install s...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/s")))

(eval-when-compile
  (el-clone :repo "vspinu/sesman"))

(with-delayed-execution-priority-high
 (message "Install sesman...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/sesman")))

(eval-when-compile
  (el-clone :repo "skeeto/emacs-web-server"))

(with-delayed-execution-priority-high
 (message "Install emacs-web-server...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-web-server")))

(eval-when-compile
  (el-clone :repo "Malabarba/spinner.el"))

(with-delayed-execution-priority-high
 (message "Install spinner...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/spinner")))

(eval-when-compile
  (el-clone :fetcher "gitlab"
            :repo "bennya/shrink-path.el"))

(with-delayed-execution-priority-high
 (message "Install shrink-path...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/shrink-path")))

(eval-when-compile
  (el-clone :repo "politza/tablist"))

(with-delayed-execution-priority-high
 (message "Install tablist...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/tablist")))

(eval-when-compile
  (el-clone :repo "kaushalmodi/tomelr"))

(with-delayed-execution-priority-high
 (message "Install tomelr...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/tomelr")))

(eval-when-compile
  (el-clone :repo "alphapapa/ts.el"))

(with-delayed-execution-priority-high
 (message "Install ts...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ts")))

(eval-when-compile
  (el-clone :repo "zkry/yaml.el"))

(with-delayed-execution-priority-high
 (message "Install yaml...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/yaml")))

(eval-when-compile
  (el-clone :repo "joostkremers/visual-fill-column"))

(with-delayed-execution-priority-high
 (message "Install visual-fill-column...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/visual-fill-column")))

(eval-when-compile
  (el-clone :repo "skeeto/emacs-web-server"))

(with-delayed-execution-priority-high
 (message "Install emacs-web-server...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-web-server")))

(eval-when-compile
  (el-clone :repo "ahyatt/emacs-websocket"))

(with-delayed-execution-priority-high
 (message "Install emacs-websocket...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-websocket")))

(eval-when-compile
  (el-clone :repo "edivangalindo/gh-test"))

(with-delayed-execution-priority-high
 (message "Install gh-test...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/gh-test")))

(eval-when-compile
  (el-clone :repo "sigma/gh.el"))

(with-delayed-execution-priority-high
 (message "Install gh...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/gh")))

(eval-when-compile
  (el-clone :repo "eschulte/emacs-web-server" :name "web-server"))

(with-delayed-execution-priority-high
 (message "Install web-server...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/web-server")))


(eval-when-compile
  (el-clone :repo "emacs-php/apache-mode"))

(with-delayed-execution
 (message "Install apache-mode")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/apache-mode"))

 (autoload-if-found '(apache-mode) "apache-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\.htaccess$" . apache-mode)))

(eval-when-compile
  (el-clone :repo "bazelbuild/emacs-bazel-mode"))

(with-delayed-execution
 (message "Install bazel-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-bazel-mode"))
 (autoload-if-found '(bazel-mode) "bazel" nil t))

(eval-when-compile
  (el-clone :repo "Wilfred/bison-mode"))

(with-delayed-execution
 (message "Install bison-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/bison-mode"))

 (autoload-if-found '(bison-mode flex-mode jison-mode) "bison-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.y\\'" . bison-mode))
 (add-to-list 'auto-mode-alist '("\\.l\\'" . flex-mode))
 (add-to-list 'auto-mode-alist '("\\.jison\\'" . jison-mode)))

(eval-when-compile
  (el-clone :repo "Wilfred/cask-mode"))

(with-delayed-execution
 (message "Install cask-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/cask-mode"))

 (autoload-if-found '(cask-mode) "cask-mode" nil t)

 (add-to-list 'auto-mode-alist '("/Cask\\'" . cask-mode)))

(eval-when-compile
  (el-clone :fetcher "gitlab"
            :repo "worr/cfn-mode"))

(with-delayed-execution
 (message "Install cfn-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/cfn-mode/cfn-mode"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/cfn-mode/flycheck-cfn"))

 (autoload-if-found '(cfn-mode) "cfn-mode" nil t)
 (autoload-if-found '(flycheck-cfn-setup) "flycheck-cfn" nil t)

 (add-to-list 'magic-mode-alist '("\\(---\n\\)?AWSTemplateFormatVersion:" . cfn-mode))

 (with-eval-after-load 'cfn-mode
   (add-hook 'cfn-mode-hook #'flycheck-cfn-setup)))

(when my/enable-clojure-load
  (load (locate-user-emacs-file "extras/clojure-load.el")))


(eval-when-compile
  (el-clone :repo "emacsmirror/cmake-mode"))

(with-delayed-execution
 (message "Install cmake...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/cmake-mode"))

 (autoload-if-found '(cmake-mode) "cmake-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\.cmake$" . cmake-mode)))

(eval-when-compile
  (el-clone :repo "defunkt/coffee-mode"))

(with-delayed-execution
 (message "Install coffee-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/coffee-mode"))

 (autoload-if-found '(coffee-mode) "coffee-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\.coffee$" . coffee-mode)))

(add-to-list 'auto-mode-alist '("\\.cnf$" . conf-mode))
(add-to-list 'auto-mode-alist '("yabairc$" . conf-mode))
(add-to-list 'auto-mode-alist '("skhdrc$" . conf-mode))

(eval-when-compile
  (el-clone :repo "emacs-pe/crontab-mode"))

(with-delayed-execution
 (message "Install crontab-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/crontab-mode"))

 (autoload-if-found '(crontab-mode) "crontab-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\.?cron\\(tab\\)?\\'" . crontab-mode)))

(eval-when-compile
  (el-clone :repo "emacs-csharp/csharp-mode"))

(with-delayed-execution
 (message "Install csharp-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/csharp-mode"))

 (autoload-if-found '(csharp-mode) "csharp-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\.cs$" . csharp-mode)))

(with-eval-after-load 'css-mode
  (add-hook 'css-mode-hook #'lsp-deferred))

(eval-when-compile
  (el-clone :repo "emacsmirror/csv-mode"))

(with-delayed-execution
 (message "Install csv-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/csv-mode"))

 (autoload-if-found '(csv-mode) "csv-mode" nil t)
 (push '("\\.csv$" . csv-mode) auto-mode-alist))

(eval-when-compile
  (el-clone :repo "emacsmirror/cuda-mode"))

(with-delayed-execution
 (message "Install cuda-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/cuda-mode"))

 (autoload-if-found '(cuda-mode) "cuda-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\.cu$" . cuda-mode)))

(eval-when-compile
  (el-clone :repo "jpellerin/emacs-crystal-mode"))

(with-delayed-execution
 (message "Install crystal-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-crystal-mode"))

 (autoload-if-found '(crystal-mode) "crystal-mode" nil t)

 (add-to-list 'auto-mode-alist '("Projectfile$" . crystal-mode))
 (add-to-list 'auto-mode-alist
              (cons (purecopy (concat "\\(?:\\."
                                      "cr"
                                      "\\)\\'")) 'crystal-mode)))

(eval-when-compile
  (el-clone :repo "bradyt/dart-mode"))

(with-delayed-execution
 (message "Install dart-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/dart-mode"))

 (autoload-if-found '(dart-mode) "dart-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\.dart$" . dart-mode)))

(eval-when-compile
  (el-clone :repo "ccod/dbd-mode"))

(with-delayed-execution
 (message "Install dbd-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/dbd-mode"))

 (autoload-if-found '(dbdiagram-mode) "dbdiagram-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.dbd\\'" . dbdiagram-mode))
 (add-to-list 'auto-mode-alist '("\\.dbml\\'" . dbdiagram-mode)))

(eval-when-compile
  (el-clone :repo "psibi/dhall-mode"))

(with-delayed-execution
 (message "Install dhall-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/dhall-mode"))

 (autoload-if-found '(dhall-mode) "dhall-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\.dhall$" . dhall-mode)))

(eval-when-compile
  (el-clone :repo "wbolster/emacs-direnv"))

(with-delayed-execution
 (message "Install direnv-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-direnv"))

 (autoload-if-found '(direnv-mode direnv-envrc-mode) "direnv" nil t)
 (add-to-list 'auto-mode-alist '("\\.envrc" . direnv-envrc-mode)))

(eval-when-compile
  (el-clone :repo "meqif/docker-compose-mode"))

(with-delayed-execution
 (message "Install docker-comopse-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/docker-compose-mode"))

 (autoload-if-found '(docker-compose-mode) "docker-compose-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\docker-compose*" . docker-compose-mode)))

(eval-when-compile
  (el-clone :repo "spotify/dockerfile-mode"))

(with-delayed-execution
 (message "Install dockerfile-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/dockerfile-mode"))

 (autoload-if-found '(dockerfile-mode) "dockerfile-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\Dockerfile$" . dockerfile-mode))
 (add-to-list 'auto-mode-alist '("\\Dockerfile_Ecs$" . dockerfile-mode))
 (add-to-list 'auto-mode-alist '("\\Dockerfile_EcsDeploy" . dockerfile-mode))

 (with-eval-after-load 'dockerfile-mode
   (add-hook 'dockerfile-mode-hook #'flycheck-mode)))

(eval-when-compile
  (el-clone :repo "preetpalS/emacs-dotenv-mode"))

(with-delayed-execution
 (message "Install dotenv-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-dotenv-mode"))

 (autoload-if-found '(dotenv-mode) "dotenv-mode" nil t)
 (add-to-list 'auto-mode-alist '(".env" . dotenv-mode))
 (add-to-list 'auto-mode-alist '("\\.env\\..*\\'" . dotenv-mode)))

(eval-when-compile
  (el-clone :repo "elixir-editors/emacs-elixir"))

(with-delayed-execution
 (message "Install elixir-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-elixir"))

 (autoload-if-found '(elixir-mode) "elixir-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.elixir$" . elixir-mode))
 (add-to-list 'auto-mode-alist '("\\.ex$" . elixir-mode))
 (add-to-list 'auto-mode-alist '("\\.exs$" . elixir-mode))
 (add-to-list 'auto-mode-alist '("mix\\.lock" . elixir-mode)))

(eval-when-compile
  (el-clone :repo "jcollard/elm-mode"))

(with-delayed-execution
 (message "Install elm-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/elm-mode"))

 (autoload-if-found '(elm-mode) "elm-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\.elm$" . elm-mode)))

(with-delayed-execution
 (message "Install emacs-lisp-mode...")
 (add-to-list 'auto-mode-alist '("Keg" . emacs-lisp-mode)))

(eval-when-compile
  (el-clone :repo "wwwjfy/emacs-fish"))

(with-delayed-execution
 (message "Install fish-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-fish"))

 (autoload-if-found '(fish-mode) "fish-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.fish$" . fish-mode))

 (with-eval-after-load 'fish-mode
   (setopt fish-enable-auto-indent t)))

(eval-when-compile
  (el-clone :repo "larsbrinkhoff/forth-mode"))

(with-delayed-execution
 (message "Install forth-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/forth-mode"))

 (autoload-if-found '(forth-mode) "forth-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.f$" . forth-mode))
 (add-to-list 'auto-mode-alist '("\\.fs$" . forth-mode))
 (add-to-list 'auto-mode-alist '("\\.fth$" . forth-mode))
 (add-to-list 'auto-mode-alist '("\\.forth$" . forth-mode))
 (add-to-list 'auto-mode-alist '("\\.4th$" . forth-mode)))

(with-delayed-execution
 (message "Install fortran...")
 (autoload-if-found '(f90-mode) "f90" nil t)
 (add-to-list 'auto-mode-alist '("\\.f\\(y90\\|y?pp\\)\\'" . f90-mode))
 (with-eval-after-load 'f90
   (add-hook 'f90-mode-hook #'lsp)))

(eval-when-compile
  (el-clone :repo "fsharp/emacs-fsharp-mode"))

(with-delayed-execution
 (message "Install fsharp-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-fsharp-mode"))

 (autoload-if-found '(fsharp-mode) "fsharp-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\.fs[iylx]?$" . fsharp-mode)))

(eval-when-compile
  (el-clone :repo "magit/git-modes"))

(with-delayed-execution
 (message "Install git-modes...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/git-modes"))
 (add-to-list 'load-path (locate-user-emacs-file (concat "el-clone/git-modes")))

 (autoload-if-found '(gitignore-mode gitconfig-mode gitattributes-mode) "git-modes" nil t)

 ;; gitignore-mode
 (add-to-list 'auto-mode-alist '("\\.dockerignore$" . gitignore-mode))
 (add-to-list 'auto-mode-alist '("\\.gitignore$" . gitignore-mode))
 (add-to-list 'auto-mode-alist '("\\.prettierignore$" . gitignore-mode))
 (add-to-list 'auto-mode-alist '("/git/ignore\\'" . gitignore-mode))
 (add-to-list 'auto-mode-alist '("/git/ignore\\'" . gitignore-mode))
 (add-to-list 'auto-mode-alist '("CODEOWNERS" . gitignore-mode))

 ;; gitconfig-mode
 (add-to-list 'auto-mode-alist '("\\.git-pr-release$" . gitconfig-mode))
 (add-to-list 'auto-mode-alist '("\\.editorconfig$" . gitconfig-mode))
 (add-to-list 'auto-mode-alist '("\\.gitconfig$" . gitconfig-mode))
 (add-to-list 'auto-mode-alist '("/\\.git/config\\'" . gitconfig-mode))
 (add-to-list 'auto-mode-alist '("/modules/.*/config\\'" . gitconfig-mode))
 (add-to-list 'auto-mode-alist '("/git/config\\'" . gitconfig-mode))
 (add-to-list 'auto-mode-alist '("/\\.gitmodules\\'" . gitconfig-mode))
 (add-to-list 'auto-mode-alist '("/etc/gitconfig\\'" . gitconfig-mode))

 ;; gitattributes
 (add-to-list 'auto-mode-alist '("/\\.gitattributes\\'" . gitattributes-mode))
 (add-to-list 'auto-mode-alist '("\.gitattributes$" . gitattributes-mode))
 (add-to-list 'auto-mode-alist '("/info/attributes\\'" . gitattributes-mode))
 (add-to-list 'auto-mode-alist '("/git/attributes\\'" . gitattributes-mode)))

(eval-when-compile
  (el-clone :repo "jimhourihan/glsl-mode"))

(with-delayed-execution
 (message "Install glsl-mode")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/glsl-mode"))

 (autoload-if-found '(glsl-mode) "glsl-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.vsh$" . glsl-mode))
 (add-to-list 'auto-mode-alist '("\\.fsh$" . glsl-mode)))

(eval-when-compile
  (el-clone :repo "dominikh/go-mode.el"))

(with-delayed-execution
 (message "Install go-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/go-mode"))

 (autoload-if-found '(go-mode) "go-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.go$" . go-mode))
 (add-to-list 'auto-mode-alist '("^go.mod$" . go-mode))

 (with-eval-after-load 'go-mode
   ;; config
   (setopt gofmt-command "goimports")

   ;; hook
   (add-hook 'before-save-hook #'gofmt-before-save)))

(eval-when-compile
  (el-clone :repo "jacobono/emacs-gradle-mode"))

(with-delayed-execution
 (message "Install gradle-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-gradle-mode"))

 (autoload-if-found '(gradle-mode) "gradle-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.gradle$" . gradle-mode)))

(eval-when-compile
  (el-clone :repo "davazp/graphql-mode"))

(with-delayed-execution
 (message "Install graphql-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/graphql-mode"))

 (autoload-if-found '(graphql-mode) "graphql-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\.graphql\\'" . graphql-mode))

 (with-eval-after-load 'graphql-mode
   (setopt graphql-indent-level 4)))

(eval-when-compile
  (el-clone :repo "ppareit/graphviz-dot-mode"))

(with-delayed-execution
 (message "Install graphviz-dot-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/graphviz-dot-mode"))

 (autoload-if-found '(graphviz-dot-mode) "graphviz-dot-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.dot\\'" . graphviz-dot-mode))
 (add-to-list 'auto-mode-alist '("\\.gv\\'" . graphviz-dot-mode))

 (with-eval-after-load 'graphviz-dot-mode
   (setopt graphviz-dot-auto-indent-on-semi nil)
   (setopt graphviz-dot-indent-width 2)))

(eval-when-compile
  (el-clone :repo "Groovy-Emacs-Modes/groovy-emacs-modes"))

(with-delayed-execution
 (message "Install groovy-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/groovy-emacs-modes"))

 (autoload-if-found '(groovy-mode) "groovy-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.g\\(?:ant\\|roovy\\|radle\\)\\'" . groovy-mode))
 (add-to-list 'auto-mode-alist '("/Jenkinsfile\\'" . groovy-mode))
 (add-to-list 'interpreter-mode-alist '("groovy" . groovy-mode)))

(eval-when-compile
  (el-clone :repo "hhvm/hack-mode"))

(with-delayed-execution
 (message "Install hack-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/hack-mode"))

 (autoload-if-found '(hack-mode) "hack-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.hack$" . hack-mode))
 (add-to-list 'auto-mode-alist '("\\.hck$" . hack-mode))
 (add-to-list 'auto-mode-alist '("\\.hhi$" . hack-mode)))

(eval-when-compile
  (el-clone :repo "haskell/haskell-mode"))

(with-delayed-execution
 (message "Install haskell-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/haskell-mode"))

 (autoload-if-found '(haskell-doc-current-info) "haskell-doc" nil t)
 (autoload-if-found '(haskell-mode) "haskell-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.hs$" . haskell-mode))
 (add-to-list 'auto-mode-alist '("\\.cable$" . haskell-mode)))

(eval-when-compile
  (el-clone :repo "hylang/hy-mode"))

(with-delayed-execution
 (message "Install hy-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/hy-mode"))

 (autoload-if-found '(hy-mode) "hy-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.hy$" . hy-mode)))

(eval-when-compile
  (el-clone :repo "Lindydancer/ini-mode"))

(with-delayed-execution
 (message "Install ini-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ini-mode"))

 (autoload-if-found '(ini-mode) "ini-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.ini$" . ini-mode)))

(eval-when-compile
  (el-clone :repo "brianc/jade-mode"))

(with-delayed-execution
 (message "Install jade-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/jade-mode"))

 (autoload-if-found '(jade-mode) "jade-mode" nil t)
 (autoload-if-found '(stylus-mode) "stylus-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.jade$" . jade-mode))
 (add-to-list 'auto-mode-alist '("\\.styl\\'" . stylus-mode)))

(with-delayed-execution
 (message "Install java-mode...")
 (autoload-if-found '(java-mode) "java-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\.java$" . java-mode)))

(eval-when-compile
  (el-clone :repo "mooz/js2-mode"))

(with-delayed-execution
 (message "Install js2-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/js2-mode"))

 (autoload-if-found '(js2-mode) "js2-mode" nil t)

 ;; js-mode
 (add-to-list 'auto-mode-alist '("\\.js$" . js-mode))
 (add-to-list 'auto-mode-alist '("\\.mjs$" . js-mode))

 ;; js2-mode
 ;; (add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
 ;; (add-to-list 'auto-mode-alist '("\\.mjs$" . js2-mode))

 (with-eval-after-load 'js2-mode
   ;; config
   (setopt js2-strict-missing-semi-warning nil)
   (setopt js2-missing-semi-one-line-override nil)))

(eval-when-compile
  (el-clone :repo "Sterlingg/json-snatcher")
  (el-clone :repo "joshwnj/json-mode"))

(with-delayed-execution
 (message "Install json-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/json-snatcher"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/json-mode"))

 (autoload-if-found '(json-mode) "json-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.json$" . json-mode))
 (add-to-list 'auto-mode-alist '("\\.textlintrc$" . json-mode))
 (add-to-list 'auto-mode-alist '("\\.prettierrc$" . json-mode))
 (add-to-list 'auto-mode-alist '("\\.markuplintrc$" . json-mode))

 (with-eval-after-load 'json-mode
   (add-hook 'json-mode-hook #'flycheck-mode)))

(eval-when-compile
  (el-clone :repo "tminor/jsonnet-mode"))

(with-delayed-execution
 (message "Install jsonnet-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/jsonnet-mode"))
 (autoload-if-found '(jsonnet-mode
                      jsonnet-eval-buffer
                      jsonnet-jump
                      jsonnet-reformat-buffer) "jsonnet-mode" nil t)

 (add-to-list 'auto-mode-alist (cons "\\.jsonnet\\'" 'jsonnet-mode))
 (add-to-list 'auto-mode-alist (cons "\\.libsonnet\\'" 'jsonnet-mode))

 (with-eval-after-load 'jsonnet-mode
   ;; config
   (setopt jsonnet-indent-level 4)

   ;; keybind
   (define-key jsonnet-mode-map (kbd "C-c C-c") #'jsonnet-eval-buffer)
   (define-key jsonnet-mode-map (kbd "C-c C-f") #'jsonnet-jump)
   (define-key jsonnet-mode-map (kbd "C-c C-r") #'jsonnet-reformat-buffer)

   ;; hook
   (add-hook 'jsonnet-mode-hook #'(lambda ()
                                    (require 'lsp-jsonnet)
                                    (lsp)))))

(eval-when-compile
  (el-clone :repo "Emacs-Kotlin-Mode-Maintainers/kotlin-mode"))

(with-delayed-execution
 (message "Install kotlin-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/kotlin-mode"))

 (autoload-if-found '(kotlin-mode) "kotlin-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.kts?\\'" . kotlin-mode)))

(with-delayed-execution
 (autoload-if-found '(lisp-mode) "lisp-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\.lemrc$" . lisp-mode))
 (add-to-list 'auto-mode-alist '("\\.sbclrc$" . lisp-mode)))

(eval-when-compile
  (el-clone :repo "immerrr/lua-mode"))

(with-delayed-execution
 (message "Install lua-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/lua-mode"))

 (autoload-if-found '(lua-mode) "lua-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.lua$" . lua-mode)))

(eval-when-compile
  (el-clone :repo "polymode/poly-markdown")
  (el-clone :repo "jrblevin/markdown-mode"))

(with-delayed-execution
 (message "Install markdown-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/poly-markdown"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/markdown-mode"))

 (autoload-if-found '(markdown-mode) "markdown-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))
 (add-to-list 'auto-mode-alist '("\\.markdown$" . markdown-mode))

 (with-eval-after-load 'markdown-mode
   ;; config
   (setopt markdown-code-lang-modes (append '(("diff" . diff-mode)
                                              ("hs" . haskell-mode)
                                              ("html" . web-mode)
                                              ("ini" . conf-mode)
                                              ("js" . web-mode)
                                              ("jsx" . web-mode)
                                              ("md" . markdown-mode)
                                              ("pl6" . raku-mode)
                                              ("py" . python-mode)
                                              ("rb" . ruby-mode)
                                              ("rs" . rustic-mode)
                                              ("sqlite3" . sql-mode)
                                              ("ts" . typescript-mode)
                                              ("typescript" . typescript-mode)
                                              ("tsx" . web-mode)
                                              ("yaml". yaml-mode)
                                              ("zsh" . sh-mode)
                                              (when my/enable-php-load ("php" . php-mode)))
                                            markdown-code-lang-modes))

   ;; markdown
   (add-hook 'markdown-mode #'orgtbl-mode)))

(eval-when-compile
  (el-clone :repo "abrochard/mermaid-mode"))

(with-delayed-execution
 (message "Install mermaid-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/mermaid-mode"))

 (autoload-if-found '(mermaid-mode) "mermaid-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.mmd\\'" . mermaid-mode)))

(with-delayed-execution
 (autoload-if-found '(makefile-mode) "makefile-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.mk$" . makefile-mode))
 (add-to-list 'auto-mode-alist '("Makefile" . makefile-mode))

 (with-eval-after-load 'makefile-mode
   ;; config
   (setopt makefile-electric-keys t)

   ;; hook
   (add-hook 'makefile-mode #'flycheck-mode)))

(eval-when-compile
  (el-clone :repo "skeeto/nasm-mode"))

(with-delayed-execution
 (message "Install nasm-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/nasm-mode"))

 (autoload-if-found '(nasm-mode) "nasm-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.s$" . nasm-mode)))

(eval-when-compile
  (el-clone :repo "Fuco1/neon-mode"))

(with-delayed-execution
 (message "Install neon-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/neon-mode"))

 (autoload-if-found '(neon-mode) "neon-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.neon$" . neon-mode)))

(eval-when-compile
  (el-clone :repo "nim-lang/nim-mode"))

(with-delayed-execution
 (message "Install nim-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/nim-mode"))

 (autoload-if-found '(nim-mode) "nim-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.nim\\'" . nim-mode)))

(eval-when-compile
  (el-clone :repo "ninja-build/ninja"))

(with-delayed-execution
 (message "Install ninja-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ninja"))

 (autoload-if-found '(ninja-mode) "ninja-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.ninja$" . ninja-mode)))

(eval-when-compile
  (el-clone :repo "NixOS/nix-mode"))

(with-delayed-execution
 (message "Install nix-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/nix-mode"))

 (autoload-if-found '(nix-mode) "nix-mode" nil t)
 (autoload-if-found '(nix-drv-mode) "nix-drv-mode" nil t)
 (autoload-if-found '(nix-shell-unpack nix-shell-configure nix-shell-build) "nix-shell" nil t)
 (autoload-if-found '(nix-repl) "nix-repl" nil t)
 (autoload-if-found '(nix-format-before-save) "nix-format" nil t)

 (add-to-list 'auto-mode-alist '("\\.nix$" . nix-mode))
 (add-to-list 'auto-mode-alist '("\\.drv$" . nix-drv-mode))

 (add-hook 'before-save-hook #'nix-format-before-save))

(eval-when-compile
  (el-clone :repo "ajc/nginx-mode"))

(with-delayed-execution
 (message "Install nginx-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/nginx-mode"))

 (autoload-if-found '(nginx-mode) "nginx-mode" nil t)

 (add-to-list 'auto-mode-alist '("nginx\\.conf\\'" . nginx-mode))
 (add-to-list 'auto-mode-alist '("/nginx/.+\\.conf\\'" . nginx-mode))
 (add-to-list 'auto-mode-alist '("/nginx/sites-\\(?:available\\|enabled\\)/" . nginx-mode))

 (with-eval-after-load 'nginx-mode
   (setopt nginx-indent-tabs-mode t)))

(eval-when-compile
  (el-clone :repo "wasamasa/nov.el"))

(with-delayed-execution
 (message "Install nov-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/nov"))

 (autoload-if-found '(nov-mode) "nov" nil t)

 (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))

 (with-eval-after-load 'nov
   (add-hook 'nov-mode-hook #'(lambda () (view-mode -1)))))

(eval-when-compile
  (el-clone :repo "orgcandman/pcap-mode"))

(with-delayed-execution
 (message "Install pcap-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/pcap-mode"))

 (autoload-if-found '(pcap-mode) "pcap" nil t)

 (add-to-list 'auto-mode-alist '("\\.pcap$" . pcap-mode)))

(when my/enable-php-load
  (load (locate-user-emacs-file "extras/php-load.el")))

(eval-when-compile
  (el-clone :repo "skuro/plantuml-mode"))

(with-delayed-execution
 (message "Install plantuml-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/plantuml-mode"))

 (autoload-if-found '(plantuml-mode) "plantuml-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.pu$" . plantuml-mode)))

(eval-when-compile
  (el-clone :repo "protocolbuffers/protobuf"))

(with-delayed-execution
 (message "Install protobuf-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/protobuf/editors"))

 (autoload-if-found '(protobuf-mode) "protobuf-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.proto\\'" . protobuf-mode)))

(eval-when-compile
  (el-clone :repo "hlissner/emacs-pug-mode"))

(with-delayed-execution
 (message "Install pug-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-pug-mode"))

 (autoload-if-found '(pug-mode) "pug-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.pug$" . pug-mode)))

(eval-when-compile
  (el-clone :repo "pimeys/emacs-prisma-mode"))

(with-delayed-execution
 (message "Install prisma-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-prisma-mode"))

 (autoload-if-found '(prisma-mode) "prisma-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.prisma" . prisma-mode)))

(eval-when-compile
  (el-clone :repo "ptrv/processing2-emacs"))

(with-delayed-execution
 (message "Install processing-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/processing2-emacs"))

 (autoload-if-found '(processing-mode) "processing-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.pde$" . processing-mode))

 (with-eval-after-load 'processing-mode
   (setopt processing-location "/opt/processing/processing-java")
   (setopt processing-output-dir "/tmp")))

(eval-when-compile
  (el-clone :fetcher "gitlab"
            :repo "python-mode-devs/python-mode"))

(with-delayed-execution
 (message "Install python-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/python-mode"))

 (autoload-if-found '(python-mode) "python-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.py$" . python-mode)))

(eval-when-compile
  (el-clone :repo "emacsorphanage/qt-pro-mode"))

(with-delayed-execution
 (message "Install qt-pro-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/qt-pro-mode"))

 (autoload-if-found '(qt-pro-mode) "qt-pro-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.pr[io]$" . qt-pro-mode)))

(eval-when-compile
  (el-clone :repo "emacs-php/robots-txt-mode"))

(with-delayed-execution
 (message "Install robots-txt-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/robots-txt-mode"))

 (autoload-if-found '(robots-txt-mode) "robots-txt-mode" nil t)

 (add-to-list 'auto-mode-alist '("/robots\\.txt\\'" . robots-txt-mode)))

(with-delayed-execution
 (message "Install ruby-mode...")
 (autoload-if-found '(ruby-mode) "ruby-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
 (add-to-list 'auto-mode-alist '("\\.irbrc$" . ruby-mode))
 (add-to-list 'auto-mode-alist '("Capfile" . ruby-mode))
 (add-to-list 'auto-mode-alist '("Gemfile" . ruby-mode))
 (add-to-list 'auto-mode-alist '("Schemafile" . ruby-mode))
 (add-to-list 'auto-mode-alist '(".pryrc" . ruby-mode))
 (add-to-list 'auto-mode-alist '("Fastfile" . ruby-mode))
 (add-to-list 'auto-mode-alist '("Matchfile" . ruby-mode))
 (add-to-list 'auto-mode-alist '("Procfile" . ruby-mode))
 (add-to-list 'auto-mode-alist '(".git-pr-template" . ruby-mode))
 (add-to-list 'auto-mode-alist '(".gemrc" . ruby-mode))
 (add-to-list 'auto-mode-alist '("\\.Brewfile" . ruby-mode))

 (with-eval-after-load 'ruby-mode
   ;; config
   (setopt ruby-insert-encoding-magic-comment nil)))

(eval-when-compile
  (el-clone :repo "rust-lang/rust-mode"))

(with-delayed-execution
 (message "Install rust-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/rust-mode"))

 (autoload-if-found '(rust-mode) "rust-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\.rs$" . rust-mode))

 (with-eval-after-load 'rust-mode
   (setopt rust-format-on-save t)))

(eval-when-compile
  (el-clone :repo "hvesalai/emacs-scala-mode"))

(with-delayed-execution
 (message "Install scala-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-scala-mode"))

 (autoload-if-found '(scala-mode) "scala-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.scala$" . scala-mode)))

(with-delayed-execution
 (message "Install scheme...")
 (autoload-if-found '(scheme-mode) "scheme-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\.scheme$" . scheme-mode))
 (add-to-list 'auto-mode-alist '(".guix-channel" . scheme-mode))
 (with-eval-after-load 'scheme
   (setopt scheme-program-name "gosh -i")))

(eval-when-compile
  (el-clone :repo "openscad/emacs-scad-mode"))

(with-delayed-execution
 (message "Install scad-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-scad-mode"))
 (autoload-if-found '(scad-mode) "scad-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.scad\\'" . scad-mode)))

(eval-when-compile
  (el-clone :repo "antonj/scss-mode"))

(with-delayed-execution
 (message "Install scss-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/scss-mode"))

 (autoload-if-found '(scss-mode) "scss-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\.scss$" . scss-mode))
 (add-to-list 'auto-mode-alist '("\\.sass$" . scss-mode))

 (with-eval-after-load 'scss-mode
   (add-hook 'scss-mode-hook #'flycheck-mode)
   (add-hook 'scss-mode-hook #'(lambda ()
                                 (let ((lsp-diagnostics-provider :none))
                                   (lsp-deferred))))))

(with-delayed-execution
 (autoload-if-found '(shell-mode) "shell-mode" nil t)
 (define-derived-mode console-mode shell-mode "console"))

(eval-when-compile
  (el-clone :repo "slim-template/emacs-slim"))

(with-delayed-execution
 (message "Install slim-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-slim"))

 (autoload-if-found '(slim-mode) "slim-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.slim$" . slim-mode)))

(eval-when-compile
  (el-clone :repo "ethereum/emacs-solidity"))

(with-delayed-execution
 (message "Install solidity-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-solidity"))

 (autoload-if-found '(solidity-mode) "solidity-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.sol$" . solidity-mode)))

(eval-when-compile
  (el-clone :repo "jhgorrell/ssh-config-mode-el"))

(with-delayed-execution
 (message "Install ssh-config-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ssh-config-mode-el"))

 (autoload-if-found '(ssh-config-mode ssh-known-hosts-mode ssh-authorized-keys-mode) "ssh-config-mode" nil t)

 (add-to-list 'auto-mode-alist '("/\\.ssh/config\\(\\.d/.*\\.conf\\)?\\'" . ssh-config-mode))
 (add-to-list 'auto-mode-alist '("/sshd?_config\\(\\.d/.*\\.conf\\)?\\'" . ssh-config-mode))
 (add-to-list 'auto-mode-alist '("/known_hosts\\'" . ssh-config-mode))
 (add-to-list 'auto-mode-alist '("/authorized_keys2?\\'" . ssh-config-mode)))

(with-eval-after-load 'sql
  (load-library "sql-indent")

  ;; config
  (setopt indent-tabs-mode nil)
  (setopt sql-user "root")
  (setopt sql-password "P@ssw0rd")
  (setopt sql-server "127.0.0.1")
  (setopt sql-port 13306)
  (setopt sql-mysql-login-params '(server port user password database))

  ;; hook
  (add-hook 'sql-mode-hook #'flycheck-mode))

(eval-when-compile
  (el-clone :repo "swift-emacs/swift-mode"))

(with-delayed-execution
 (message "Install swift-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/swift-mode"))

 (autoload-if-found '(swift-mode) "swift-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.swift$" . swift-mode)))

(eval-when-compile
  (el-clone :repo "vapniks/syslog-mode"))

(with-delayed-execution
 (message "Install syslog-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/syslog-mode"))

 (autoload-if-found '(syslog-mode) "syslog-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.log$" . syslog-mode)))

(eval-when-compile
  (el-clone :repo "holomorph/systemd-mode"))

(with-delayed-execution
 (message "Install systemd-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/systemd-mode"))

 (autoload-if-found '(systemd-mode) "systemd" nil t)

 (add-to-list 'auto-mode-alist '("\\.nspawn\\'" . systemd-mode))
 (add-to-list 'auto-mode-alist `(,(rx (+? (any "a-zA-Z0-9-_.@\\")) "."
                                      (or "automount" "busname" "mount" "service" "slice"
                                          "socket" "swap" "target" "timer" "link" "netdev" "network")
                                      string-end)
                                 . systemd-mode))
 (add-to-list 'auto-mode-alist `(,(rx ".#"
                                      (or (and (+? (any "a-zA-Z0-9-_.@\\")) "."
                                               (or "automount" "busname" "mount" "service" "slice"
                                                   "socket" "swap" "target" "timer" "link" "netdev" "network"))
                                          "override.conf")
                                      (= 16 (char hex-digit)) string-end)
                                 . systemd-mode))
 (add-to-list 'auto-mode-alist `(,(rx "/systemd/" (+? anything) ".d/" (+? (not (any ?/))) ".conf" string-end)
                                 . systemd-mode)))

(eval-when-compile
  (el-clone :repo "syohex/emacs-hcl-mode")
  (el-clone :repo "emacsorphanage/terraform-mode"))

(with-delayed-execution
 (message "Install terraform-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-hcl-mode"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/terraform-mode"))

 (autoload-if-found '(hcl-mode) "hcl-mode" nil t)
 (autoload-if-found '(terraform-mode terraform-format-on-save-mode) "terraform-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.hcl$" . hcl-mode))
 (add-to-list 'auto-mode-alist '("\\.tf$" . terraform-mode))

 (with-eval-after-load 'terraform-mode
   (add-hook 'terraform-mode-hook #'terraform-format-on-save-mode)
   (add-hook 'terraform-mode-hook #'flycheck-mode)))

(with-delayed-execution
 (autoload-if-found '(conf-space-mode) "conf-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\.tigrc$" . conf-space-mode))
 (add-to-list 'auto-mode-alist '("\\.editrc$" . conf-space-mode))
 (add-to-list 'auto-mode-alist '("\\.inputrc$" . conf-space-mode))
 (add-to-list 'auto-mode-alist '("\\.colorrc$" . conf-space-mode))
 (add-to-list 'auto-mode-alist '("\\.asdfrc$" . conf-space-mode))
 (add-to-list 'auto-mode-alist '("credentials$" . conf-space-mode)))

(eval-when-compile
  (el-clone :repo "dryman/toml-mode.el"))

(with-delayed-execution
 (message "Install toml-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/toml-mode"))

 (autoload-if-found '(toml-mode) "toml-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.toml$" . toml-mode))

 (with-eval-after-load 'toml-mode
   (add-hook 'toml-mode-hook #'flycheck-mode)))

(eval-when-compile
  (el-clone :repo "nverno/tmux-mode"))

(with-delayed-execution
 (message "Install tmux-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/tmux-mode"))
 (autoload-if-found '(tmux-mode) "tmux-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\.tmux\\.conf$" . tmux-mode)))

(eval-when-compile
  (el-clone :repo "emacs-typescript/typescript.el"))

(with-delayed-execution
 (message "Install typescript-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/typescript"))

 (autoload-if-found '(typescript-mode) "typescript-mode" nil t)

 ;; for ts/deno
 (add-to-list 'auto-mode-alist '("\\.ts$" . typescript-mode))

 ;; for tsx
 (define-derived-mode typescript-tsx-mode typescript-mode "tsx")
 (add-to-list 'auto-mode-alist '("\\.jsx$" . typescript-tsx-mode))
 (add-to-list 'auto-mode-alist '("\\.tsx$" . typescript-tsx-mode)))

(eval-when-compile
  (el-clone :repo "damon-kwok/v-mode"))

(with-delayed-execution
 (message "Install v-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/v-mode"))

 (autoload-if-found '(v-mode v-menu v-format-buffer) "v-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\(\\.v?v\\|\\.vsh\\)$" . v-mode))

 (with-eval-after-load 'v-mode
   (define-key v-mode-map (kbd "M-z") #'v-menu)
   (define-key v-mode-map (kbd "C-c C-f") #'v-format-buffer)))

(eval-when-compile
  (el-clone :repo "AdamNiederer/ssass-mode")
  (el-clone :repo "AdamNiederer/vue-html-mode")
  (el-clone :repo "purcell/mmm-mode")
  (el-clone :repo "Fanael/edit-indirect")
  (el-clone :repo "AdamNiederer/vue-mode"))

(with-delayed-execution
 (message "Install vue-mode...")

 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ssass-mode"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/vue-html-mode"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/mmm-mode"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/edit-indirect"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/vue-mode"))

 (autoload-if-found '(vue-mode) "vue-mode" nil t)
 (add-to-list 'auto-mode-alist '("\\.vue$" . vue-mode))

 (with-eval-after-load 'vue-html-mode
   (setopt vue-html-extra-indent 4)))

(eval-when-compile
  (el-clone :repo "mcandre/vimrc-mode"))

(with-delayed-execution
 (message "Install vimrc-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/vimrc-mode"))

 (autoload-if-found '(vimrc-mode) "vimrc-mode" nil t)

 (add-to-list 'auto-mode-alist '("vimrc" . vimrc-mode))
 (add-to-list 'auto-mode-alist '("\\.vim\\(rc\\)?\\'" . vimrc-mode)))

(eval-when-compile
  (el-clone :repo "devonsparks/wat-mode"))

(with-delayed-execution
 (message "Install wat-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/wat-mode"))

 (autoload-if-found '(wat-mode) "wat-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.wat?\\'" . wat-mode)))

(eval-when-compile
  (el-clone :repo "fxbois/web-mode"))

(with-delayed-execution
 (message "Install web-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/web-mode"))

 (autoload-if-found '(web-mode) "web-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.html$" . web-mode))
 (add-to-list 'auto-mode-alist '("\\.erb$" . web-mode))
 (add-to-list 'auto-mode-alist '("\\.gsp$" . web-mode))
 (add-to-list 'auto-mode-alist '("\\.svg$" . web-mode))
 (add-to-list 'auto-mode-alist '("\\.tpl$" . web-mode))
 (add-to-list 'auto-mode-alist '("\\.liquid$" . web-mode))

 (with-eval-after-load 'web-mode
   (setopt web-mode-comment-style 2)
   (setopt web-mode-enable-auto-pairing nil)
   (setopt web-mode-enable-auto-indentation nil)))

(eval-when-compile
  (el-clone :repo "kawabata/wolfram-mode"))

(with-delayed-execution
 (message "Install wolfram-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/wolfram-mode"))

 (autoload-if-found '(wolfram-mode run-wolfram) "wolfram-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.m$" . wolfram-mode))
 (add-to-list 'auto-mode-alist '("\\.nb$" . wolfram-mode))
 (add-to-list 'auto-mode-alist '("\\.cbf$" . wolfram-mode))

 (with-eval-after-load 'wolfram-mode
   (setopt wolfram-path "path-to-dir")))

(eval-when-compile
  (el-clone :repo "yoshiki/yaml-mode"))

(with-delayed-execution
 (message "Install yaml-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/yaml-mode"))

 (autoload-if-found '(yaml-mode) "yaml-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.ya?ml$" . yaml-mode))
 (add-to-list 'auto-mode-alist '("\\.aclpolicy$" . yaml-mode))

 (with-eval-after-load 'yaml-mode
   (add-hook 'yaml-mode-hook #'flycheck-mode)))

(eval-when-compile
  (el-clone :repo "anachronic/yarn-mode"))

(with-delayed-execution
 (message "Install yarn-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/yarn-mode"))

 (autoload-if-found '(yarn-mode) "yarn-mode" nil t)

 (add-to-list 'auto-mode-alist '("yarn\\.lock\\'" . yarn-mode)))

(eval-when-compile
  (el-clone :repo "ziglang/zig-mode"))

(with-delayed-execution
 (message "Install zig-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/zig-mode"))

 (autoload-if-found '(zig-mode) "zig-mode" nil t)

 (add-to-list 'auto-mode-alist '("\\.zig$" . zig-mode)))

(eval-when-compile
  (el-clone :repo "kentaro/auto-save-buffers-enhanced"))

(with-delayed-execution
 (message "Install auto-save-buffers-enhanced...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/auto-save-buffers-enhanced"))

 (autoload-if-found '(auto-save-buffers-enhanced) "auto-save-buffers-enhanced" nil t)

 (with-eval-after-load 'auto-save-buffers-enhanced
   (setopt auto-save-buffers-enhanced-interval 10)))

(eval-when-compile
  (el-clone :repo "editorconfig/editorconfig-emacs"))

(with-delayed-execution
 (message "Install editorconfig...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/editorconfig-emacs"))

 (autoload-if-found '(editorconfig-mode) "editorconfig" nil t)

 (editorconfig-mode 1))

(eval-when-compile
  (el-clone :repo "Fanael/persistent-scratch"))

(with-delayed-execution
 (message "Install persistent-scratch...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/persistent-scratch"))

 (autoload-if-found '(persistent-scratch-setup-default) "persistent-scratch" nil t)

 ;; (persistent-scratch-setup-default)

 (with-eval-after-load 'persistent-scratch
   (setopt persistent-scratch-autosave-interval 100)))

(eval-when-compile
  (el-clone :repo "emacsorphanage/popwin"))

(with-delayed-execution
 (message "Install popwin...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/popwin"))

 (autoload-if-found '(popwin-mode) "popwin" nil t)

 (popwin-mode 1))

(with-delayed-execution
 (message "Install whitespace...")
 (when (autoload-if-found '(global-whitespace-mode) "whitespace" nil t)
   (if window-system
       (global-whitespace-mode 1)))
 (with-eval-after-load 'whitespace
   (setopt whitespace-style '(face tabs tab-mark spaces space-mark))
   (setopt whitespace-display-mappings '((space-mark ?\u3000 [?\u25a1])
                                         (tab-mark ?\t [?\xBB ?\t] [?\\ ?\t])))))

(eval-when-compile
  (el-clone :repo "flycheck/flycheck"))

(with-delayed-execution
 (message "Install flycheck...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/flycheck"))

 (autoload-if-found '(flycheck-mode flycheck-define-checker) "flycheck" nil t))

(with-delayed-execution
 (flycheck-define-checker textlint
   "A linter for prose."
   :command ("npx" "textlint" "--format" "unix" source-inplace)
   :error-patterns
   ((warning line-start (file-name) ":" line ":" column ": "
             (id (one-or-more (not (any " "))))
             (message (one-or-more not-newline)
                      (zero-or-more "\n" (any " ") (one-or-more not-newline)))
             line-end))
   :modes (org-mode))
 (with-eval-after-load 'flycheck
   (add-to-list 'flycheck-checkers 'textlint)))

(eval-when-compile
  (el-clone :repo "emacs-elsa/flycheck-elsa"))

(with-delayed-execution
 (message "Install flycheck-elsa...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/flycheck-elsa"))

 (autoload-if-found '(flycheck-elsa-setup) "flycheck-elsa" nil t)

 (with-eval-after-load 'elisp-mode
   (add-hook 'emacs-lisp-mode-hook #'flycheck-elsa-setup)))

(eval-when-compile
  (el-clone :repo "nbfalcon/flycheck-projectile"))

(with-delayed-execution
 (message "Install flycheck-projectile...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/flycheck-projectile"))
 (autoload-if-found '(flycheck-projectile-list-errors) "flycheck-projectile" nil t))

(eval-when-compile
  (el-clone :repo "ahungry/md4rd"))

(with-delayed-execution
 (message "Install md4rd...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/md4rd"))

 (autoload-if-found '(md4rd
                      md4rd-login
                      md4rd-visit
                      md4rd-widget-expand-all
                      md4rd-widget-collapse-all
                      md4rd-reply
                      md4rd-upvote
                      md4rd-downvote
                      md4rd-widget-toggle-line
                      md4rd-refresh-login
                      md4rd-indent-all-the-lines) "md4rd" nil t)

 (with-eval-after-load 'md4rd
   (add-hook 'md4rd-mode-hook #'md4rd-indent-all-the-lines)
   (run-with-timer 0 3540 #'md4rd-refresh-login)

   ;; config
   (setopt md4rd-subs-active '(emacs lisp+Common_Lisp prolog clojure))
   ;; (setopt md4rd--oauth-access-token "your-access-token-here")
   ;; (setopt md4rd--oauth-refresh-token "your-refresh-token-here")

   ;; keymap
   (define-key md4rd-mode-map (kbd "u") 'tree-mode-goto-parent)
   (define-key md4rd-mode-map (kbd "o") 'md4rd-open)
   (define-key md4rd-mode-map (kbd "v") 'md4rd-visit)
   (define-key md4rd-mode-map (kbd "e") 'tree-mode-toggle-expand)
   (define-key md4rd-mode-map (kbd "E") 'md4rd-widget-expand-all)
   (define-key md4rd-mode-map (kbd "C") 'md4rd-widget-collapse-all)
   (define-key md4rd-mode-map (kbd "n") 'widget-forward)
   (define-key md4rd-mode-map (kbd "j") 'widget-forward)
   (define-key md4rd-mode-map (kbd "h") 'backward-button)
   (define-key md4rd-mode-map (kbd "p") 'widget-backward)
   (define-key md4rd-mode-map (kbd "k") 'widget-backward)
   (define-key md4rd-mode-map (kbd "l") 'forward-button)
   (define-key md4rd-mode-map (kbd "q") 'kill-current-buffer)
   (define-key md4rd-mode-map (kbd "r") 'md4rd-reply)
   (define-key md4rd-mode-map (kbd "u") 'md4rd-upvote)
   (define-key md4rd-mode-map (kbd "d") 'md4rd-downvote)
   (define-key md4rd-mode-map (kbd "t") 'md4rd-widget-toggle-line)))

(with-delayed-execution
 (message "Install ansi-color...")
 (autoload 'ansi-color-for-comint-mode-on "ansi-color" "Set `ansi-color-for-comint-mode' to t." t)
 (autoload-if-found '(ansi-color-for-comint-mode-on) "ansi-color" nil t)

 (with-eval-after-load 'shell-mode
   (add-hook 'shell-mode-hook #'ansi-color-for-comint-mode-on))

 (with-eval-after-load 'compile
   (add-hook 'compilation-filter-hook #'(lambda ()
                                          (ansi-color-apply-on-region (point-min) (point-max))))))

(eval-when-compile
  (el-clone :repo "DarthFennec/highlight-indent-guides"))

(with-delayed-execution
 (message "Install highlight-indent-guides...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/highlight-indent-guides"))

 (autoload-if-found '(highlight-indent-guides-mode) "highlight-indent-guides" nil t)

 (with-eval-after-load 'yaml-mode
   (add-hook 'yaml-mode-hook 'highlight-indent-guides-mode))

 (with-eval-after-load 'highlight-indent-guides
   (setopt highlight-indent-guides-responsive 'stack)
   (setopt highlight-indent-guides-method 'bitmap)))

(eval-when-compile
  (el-clone :repo "tarsius/hl-todo"))

(with-delayed-execution
 (message "Install hl-todo...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/hl-todo"))

 (autoload-if-found '(global-hl-todo-mode) "hl-todo" nil t)

 (global-hl-todo-mode)

 (with-eval-after-load 'hl-todo
   (setopt hl-todo-keyword-faces
           '(("HOLD" . "#d0bf8f")
             ("TODO" . "#cc9393")
             ("NOW" . "#dca3a3")
             ("SOMEDAY" . "#dc8cc3")
             ("WAIT" . "#7cb8bb")
             ("DONE" . "#afd8af")
             ("FIXME" . "#cc9393")))))

(eval-when-compile
  (el-clone :repo "atomontage/xterm-color"))

(with-delayed-execution
 (message "Install xterm-color...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/xterm-color"))

 (autoload-if-found '(xterm-color-filter) "xterm-color" nil t)

 (setenv "TERM" "xterm-256color")

 (with-eval-after-load 'xterm-color
   (setopt xterm-color-preserve-properties t)))

(eval-when-compile
  (el-clone :repo "DarwinAwardWinner/amx"))

(with-delayed-execution-priority-high
 (message "Install amx...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/amx"))

 (with-eval-after-load 'amx
   (setopt amx-history-length 100)))

(eval-when-compile
  (el-clone :repo "minad/corfu"))

(with-delayed-execution
 (message "Install corfu...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/corfu"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/corfu/extensions"))

 (autoload-if-found '(global-corfu-mode) "corfu" nil t)

 (global-corfu-mode)

 (with-eval-after-load 'corfu
   (setopt corfu-auto t)
   (setopt corfu-auto-delay 0.2)
   (setopt corfu-cycle t)
   (setopt corfu-on-exact-match nil))

 (with-eval-after-load 'indent
   (setopt tab-always-indent 'complete)))

(eval-when-compile
  (el-clone :repo "minad/cape"))

(with-delayed-execution
 (message "Install cape...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/cape"))

 (autoload-if-found '(cape-file
                      cape-dabbrev
                      cape-elisp-block
                      cape-history
                      cape-keyword) "cape" nil t)

 (with-eval-after-load 'minibuffer
   (add-to-list 'completion-at-point-functions #'cape-dabbrev)
   (add-to-list 'completion-at-point-functions #'cape-file)
   (add-to-list 'completion-at-point-functions #'cape-elisp-block)
   (add-to-list 'completion-at-point-functions #'cape-history)))

(eval-when-compile
  (el-clone :repo "radian-software/prescient.el"))

(with-delayed-execution
 (message "Install prescient...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/prescient"))

 (autoload-if-found '(prescient-persist-mode) "prescient" nil t)

 (prescient-persist-mode)

 (with-eval-after-load 'prescient
   (setopt prescient-aggressive-file-save t)))

(eval-when-compile
  (el-clone :repo "jdtsmith/kind-icon"))

(with-delayed-execution
 (message "Install kind-icon...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/kind-icon"))

 (autoload-if-found '(kind-icon-margin-formatter) "kind-icon" nil t)

 (with-eval-after-load 'corfu
   (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter)))

(eval-when-compile
  (el-clone :repo "abo-abo/avy"))

(with-delayed-execution
 (message "Install avy...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/avy"))

 (autoload-if-found '(avy-goto-word-1) "avy" nil t)

 (keymap-global-set "C-:" #'avy-goto-word-1)

 (with-eval-after-load 'avy
   (setopt avy-all-windows nil)
   (setopt avy-background t)))

(eval-when-compile
  (el-clone :repo "cute-jumper/avy-zap"))

(with-delayed-execution
 (message "Install avy-zap...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/avy-zap"))

 (autoload-if-found '(avy-zap-up-to-char-dwim) "avy-zap" nil t)

 (keymap-global-set "M-z" 'avy-zap-up-to-char-dwim))

(eval-when-compile
  (el-clone :repo "magnars/expand-region.el"))

(with-delayed-execution
 (message "Install expand-region...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/expand-region"))

 (autoload-if-found '(er/expand-region) "expand-region" nil t)

 (transient-mark-mode)

 (keymap-global-set "C-M-@" 'er/expand-region))

(eval-when-compile
  (el-clone :repo "magnars/multiple-cursors.el"))

(with-delayed-execution
 (message "Install multiple-cursors...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/multiple-cursors"))

 (autoload-if-found '(mc/mark-next-like-this mc/mark-previous-like-this mc/mark-all-like-this) "multiple-cursors" nil t)

 (keymap-global-set "C->" #'mc/mark-next-like-this)
 (keymap-global-set "C-<" #'mc/mark-previous-like-this)
 (keymap-global-set "C-c C-<" #'mc/mark-all-like-this))

(with-delayed-execution
 (message "Install subword...")
 (autoload-if-found '(my/delete-forward-block) "subword" nil t)

 (keymap-global-set "M-d" #'my/delete-forward-block)

 (defun my/delete-forward-block ()
   (interactive)
   (if (eobp)
       (message "End of buffer")
     (let* ((syntax-move-point
             (save-excursion
               (skip-syntax-forward (string (char-syntax (char-after))))
               (point)))
            (subword-move-point
             (save-excursion
               (subword-forward)
               (point))))
       (kill-region (point) (min syntax-move-point subword-move-point))))))

(eval-when-compile
  (el-clone :repo "abo-abo/define-word"))

(with-delayed-execution
 (message "Install define-word...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/define-word"))

 (defun my/define-word ()
   (interactive)
   (if (use-region-p)
       (call-interactively #'define-word-at-point)
     (call-interactively #'define-word)))

 (with-eval-after-load 'define-word
   (setopt define-word-displayfn-alist
           '((wordnik . takeokunn/define-word--display-in-buffer)
             (openthesaurus . takeokunn/define-word--display-in-buffer)
             (webster . takeokunn/define-word--display-in-buffer)
             (weblio . takeokunn/define-word--display-in-buffer)))))

(eval-when-compile
  (el-clone :repo "Fuco1/dired-hacks"))

(with-delayed-execution
 (message "Install dired...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/dired-hacks"))

 (with-eval-after-load 'dired
   ;; config
   (setopt dired-dwim-target nil)
   (setopt dired-hide-details-hide-symlink-targets nil)
   (setopt dired-listing-switches "-alh")
   (setopt dired-recursive-copies 'always)
   (setopt dired-use-ls-dired nil)

   ;; hook
   (add-hook 'dired-mode-hook #'(lambda () (display-line-numbers-mode -1)))))

(with-delayed-execution
 (message "Install dired-collapse...")

 (autoload-if-found '(dired-collapse-mode) "dired-collapse" nil t)

 (with-eval-after-load 'dired
   (add-hook 'dired-mode #'dired-collapse-mode)))

(with-delayed-execution
 (message "Install dired-filter...")
 (autoload-if-found '(dired-filter-mode) "dired-filter" nil t)
 (with-eval-after-load 'dired
   (add-hook 'dired-mode #'dired-filter-mode)))

(with-delayed-execution
 (message "Install dired-narrow...")

 (autoload-if-found '(dired-narrow-mode) "dired-narrow" nil t)

 (with-eval-after-load 'dired
   (add-hook 'dired-mode-hook #'dired-narrow-mode)))

(with-delayed-execution
 (message "Install dired-open...")

 (autoload-if-found '(dired-open-file) "dired-open" nil t)

 (with-eval-after-load 'dired
   (define-key dired-mode-map [remap dired-find-file] #'dired-open-file)))

(with-delayed-execution
 (message "Install dired-ranger...")
 (autoload-if-found '() "dired-ranger" nil t))

(eval-when-compile
  (el-clone :fetcher "gitlab"
            :repo "xuhdev/dired-quick-sort"))

(with-delayed-execution
 (message "Install dired-quick-sort...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/dired-quick-sort"))

 (autoload-if-found '(dired-quick-sort-setup) "dired-quick-sort" nil t)

 (with-eval-after-load 'dired
   (add-hook 'dired-mode-hook #'dired-quick-sort-setup)))

(with-delayed-execution
 (message "Install dired-subtree...")
 (autoload-if-found '(dired-subtree-apply-filter) "dired-subtree" nil t))

(eval-when-compile
  (el-clone :repo "purcell/diredfl"))

(with-delayed-execution
 (message "Install diredfl...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/diredfl"))
 (autoload-if-found '(diredfl-global-mode) "diredfl" nil t)
 (diredfl-global-mode))

(with-delayed-execution
 (message "Install eww...")

 (defun my/eww-rename-buffer ()
   "Rename the name of current EWW buffer."
   (let* ((title (plist-get eww-data :title))
          (url (file-name-base (eww-current-url)))
          (buffer-name (or (if (and title (> (length title) 0))
                               title
                             nil)
                           url "")))
     (rename-buffer (format "eww: %s" buffer-name) t)))

 ;; config
 (with-eval-after-load 'eww
   (setopt eww-header-line-format nil)
   (setopt eww-search-prefix "http://www.google.co.jp/search?q="))

 ;; keybind
 (with-eval-after-load 'eww
   (define-key eww-mode-map (kbd "C") #'eww-set-character-encoding)
   (define-key eww-mode-map (kbd "C-j") #'eww-follow-link)
   (define-key eww-mode-map (kbd "T") #'eww-goto-title-heading)
   (define-key eww-mode-map (kbd "T") #'eww-goto-title-heading))

 ;; hooks
 (with-eval-after-load 'eww
   (add-hook 'eww-after-render #'my/eww-rename-buffer)))

(eval-when-compile
  (el-clone :repo "m00natic/eww-lnum"))

(with-delayed-execution
 (message "Install eww-lnum...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/eww-lnum"))

 (autoload-if-found '(eww-lnum-follow eww-lnum-universal) "eww-lnum" nil t)

 (with-eval-after-load 'eww
   (define-key eww-mode-map "f" #'eww-lnum-follow)
   (define-key eww-mode-map "F" #'eww-lnum-universal)))

(with-delayed-execution
 (message "Install recentf...")
 (autoload-if-found '(recentf-mode) "recentf" nil t)
 (recentf-mode 1)
 (with-eval-after-load 'recentf
   (setopt recentf-max-menu-items 10000)
   (setopt recentf-max-saved-items 10000)
   (setopt recentf-auto-cleanup 'never)
   (setopt recentf-save-file  "~/.emacs.d/.recentf")
   (setopt recentf-exclude '(".recentf" "\\.gpg\\"))))

(eval-when-compile
  (el-clone :repo "rubikitch/open-junk-file"))

(with-delayed-execution
 (message "Install open-junk-file...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/open-junk-file"))

 (autoload-if-found '(open-junk-file) "open-junk-file" nil t)

 (keymap-global-set "C-x j" #'open-junk-file)

 (with-eval-after-load 'open-junk-file
   (setopt open-junk-file-format "~/.emacs.d/.junk/%Y-%m-%d-%H%M%S.")))

(eval-when-compile
  (el-clone :repo "m00natic/vlfi"))

(with-delayed-execution
 (message "Install vlfi...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/vlfi"))

 (autoload-if-found '(vlf-disable-for-function) "vlf-setup" t)

 (vlf-disable-for-function tags-verify-table "etags")
 (vlf-disable-for-function tag-find-file-of-tag-noselect "etags")
 (vlf-disable-for-function helm-etags-create-buffer "helm-tags")

 (with-eval-after-load 'dired
   (define-key dired-mode-map (kbd "V") #'dired-vlf)))

(eval-when-compile
  (el-clone :repo "Lindydancer/font-lock-studio"))

(with-delayed-execution
 (message "Install font-lock-studio...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/font-lock-studio"))

 (autoload-if-found '(font-lock-studio) "font-lock-studio" nil t))

(eval-when-compile
  (el-clone :repo "emacsmirror/gcmh"))

(with-delayed-execution
 (message "Install gcmh...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/gcmh"))

 (autoload-if-found '(gcmh-mode) "gcmh" nil t)

 (gcmh-mode)

 (defvar my/gcmh-status nil)

 (advice-add #'garbage-collect
             :before
             (defun my/gcmh-log-start (&rest _)
               (when gcmh-verbose
                 (setopt my/gcmh-status "Running GC..."))))

 (advice-add #'gcmh-message
             :override
             (defun my/gcmh-message (format-string &rest args)
               (setopt my/gcmh-status
                       (apply #'format-message format-string args))
               (run-with-timer 2 nil
                               (lambda ()
                                 (setopt my/gcmh-status nil)))))

 (with-eval-after-load 'gcmh
   ;; config
   (setopt gcmh-verbose t)))

(eval-when-compile
  (el-clone :repo "magit/transient"
            :load-paths `(,(locate-user-emacs-file "el-clone/transient/lisp")))
  (el-clone :repo "magit/ghub"
            :load-paths `(,(locate-user-emacs-file "el-clone/ghub/lisp")))
  (el-clone :repo "magit/magit-popup")
  (el-clone :repo "magit/with-editor"
            :load-paths `(,(locate-user-emacs-file "el-clone/with-editor/lisp")))
  (el-clone :repo "magit/magit"
            :load-paths `(,(locate-user-emacs-file "el-clone/magit/lisp"))))

(with-delayed-execution-priority-high
 (message "Install magit...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/transient/lisp"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ghub/lisp"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/magit-popup"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/with-editor/lisp"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/magit/lisp"))

 (autoload-if-found '(global-git-commit-mode) "git-commit" nil t)
 (autoload-if-found '(magit-status magit-blame) "magit")

 (global-git-commit-mode)

 (defun my/magit-status ()
   (interactive)
   (let ((default-directory (locate-dominating-file default-directory ".git")))
     (magit-status)))

 (keymap-global-set "C-x g" #'my/magit-status)
 (keymap-global-set "C-x G" #'magit-blame)

 (with-eval-after-load 'magit
   (setopt magit-refresh-status-buffer nil))

 (with-eval-after-load 'magit-status
   ;; config
   (setq magit-status-sections-hook
         '(magit-insert-status-headers
           ;; magit-insert-merge-log
           ;; magit-insert-rebase-sequence
           ;; magit-insert-am-sequence
           ;; magit-insert-sequencer-sequence
           ;; magit-insert-bisect-output
           ;; magit-insert-bisect-rest
           ;; magit-insert-bisect-log
           magit-insert-untracked-files
           magit-insert-unstaged-changes
           magit-insert-staged-changes
           ;; magit-insert-stashes
           magit-insert-unpushed-to-pushremote
           magit-insert-unpushed-to-upstream-or-recent
           magit-insert-unpulled-from-pushremote
           magit-insert-unpulled-from-upstream))


   ;; keybind
   (define-key magit-status-mode-map (kbd "C-j") #'magit-visit-thing))

 (with-eval-after-load 'magit-log
   (define-key magit-log-mode-map (kbd "C-j") #'magit-visit-thing))

 (with-eval-after-load 'git-commit
   (define-key git-commit-mode-map (kbd "C-h") #'delete-backward-char)))

(eval-when-compile
  (el-clone :repo "gekoke/magit-file-icons"))

(with-delayed-execution
 (message "Install magit-file-icons...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/magit-file-icons"))

 (autoload-if-found '(magit-file-icons-mode) "magit-file-icons" nil t))

;; (with-eval-after-load 'magit
;;   (add-hook 'magit-mode-hook #'magit-file-icons-mode))

(eval-when-compile
  (el-clone :repo "magit/forge"
            :load-paths `(,(locate-user-emacs-file "el-clone/forge/lisp"))))

(with-delayed-execution
 (message "Install magit-forge...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/forge/lisp")))

;; (add-hook 'magit-mode-hook #'(lambda () (require 'forge)))

(eval-when-compile
  (el-clone :repo "emacsorphanage/git-gutter"))

(with-delayed-execution
 (message "Install git-gutter...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/git-gutter"))

 (autoload-if-found '(git-gutter-mode) "git-gutter" nil t)

 (with-eval-after-load 'git-gutter
   ;; (add-hook 'prog-mode-hook #'git-gutter-mode)
   (setopt git-gutter:update-hooks '(after-save-hook after-revert-hook))))

(eval-when-compile
  (el-clone :repo "emacsorphanage/git-gutter-fringe"))

(with-delayed-execution
 (message "Install git-gutter-fringe...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/git-gutter-fringe"))

 (autoload-if-found '(git-gutter-fr:init
                      git-gutter-fr:view-diff-infos
                      git-gutter-fr:clear) "git-gutter-fringe" nil t)

 (with-eval-after-load 'git-gutter
   (setopt git-gutter-fr:side 'right-fringe)
   (setopt git-gutter:window-width -1)
   (setopt git-gutter:init-function #'git-gutter-fr:init)
   (setopt git-gutter:view-diff-function #'git-gutter-fr:view-diff-infos)
   (setopt git-gutter:clear-function #'git-gutter-fr:clear)))

(eval-when-compile
  (el-clone :repo "emacsmirror/git-timemachine"))

(with-delayed-execution
 (message "Install git-timemachine...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/git-timemachine"))

 (autoload-if-found '(git-timemachine) "git-timemachine" nil t))

(eval-when-compile
  (el-clone :repo "defunkt/gist.el"))

(with-delayed-execution
 (message "Install gist...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/gist"))

 (autoload-if-found '(gist-mode) "gist" nil t))

(eval-when-compile
  (el-clone :repo "Artawower/blamer.el"))

(with-delayed-execution
 (message "Install blamer...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/blamer"))

 (autoload-if-found '(blamer-mode) "blamer" nil t))

(eval-when-compile
  (el-clone :repo "ryuslash/git-auto-commit-mode"))

(with-delayed-execution
 (message "Install git-auto-commit-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/git-auto-commit-mode"))

 (autoload-if-found '(git-auto-commit-mode) "git-auto-commit-mode" nil t)

 (with-eval-after-load 'git-auto-commit-mode
   (setopt gac-automatically-push-p t)
   (setopt gac-silent-message-p t)
   (setopt gac-debounce-interval (* 60 60 3))
   (setopt gac-default-message "Update")))

(eval-when-compile
  (el-clone :repo "Malabarba/emacs-google-this"))

(with-delayed-execution
 (message "Install google-this...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-google-this"))

 (autoload-if-found '(google-this) "google-this" nil t))

(eval-when-compile
  (el-clone :repo "zonuexe/google-translate"))

(with-delayed-execution
 (message "Install google-translate...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/google-translate"))

 (autoload-if-found '(google-translate-at-point) "google-translate" nil t))

(with-delayed-execution
 (message "Install epa-file...")
 (autoload-if-found '(epa-file-enable) "epa-file" nil t)

 (epa-file-enable)

 (with-eval-after-load 'epa-file
   (setopt epa-file-encrypt-to '("bararararatty@gmail.com"))
   (setopt epa-file-select-keys 'silent)
   (setopt epa-file-cache-passphrase-for-symmetric-encryption t)
   (setopt epg-pinentry-mode 'loopback)

   (fset 'epg-wait-for-status 'ignore)))

(eval-when-compile
  (el-clone :repo "ueno/pinentry-el"))

(with-delayed-execution
 (message "Install pinentry...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/pinentry-el"))

 (autoload-if-found '(pinentry-start) "pinentry" nil t)
 (when-guix
  (pinentry-start)))

(eval-when-compile
  (el-clone :repo "Wilfred/helpful"))

(with-delayed-execution
 (message "Install helpful...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/helpful"))

 (autoload-if-found '(helpful-callable
                      helpful-function
                      helpful-macro
                      helpful-command
                      helpful-key
                      helpful-variable
                      helpful-at-point) "helpful" nil t)
 ;; keybinds
 (keymap-global-set "C-h f" #'helpful-callable)
 (keymap-global-set "C-h v" #'helpful-variable)
 (keymap-global-set "C-h k" #'helpful-key)
 (keymap-global-set "C-c C-d" #'helpful-at-point)
 (keymap-global-set "C-h F" #'helpful-function)
 (keymap-global-set "C-h C" #'helpful-command))

(eval-when-compile
  (el-clone :repo "skk-dev/ddskk"))

(with-delayed-execution-priority-high
 (message "Install ddskk...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ddskk"))

 (autoload-if-found '(skk-mode) "skk-autoloads" nil t)

 (keymap-global-set "C-x C-j" #'skk-mode)

 (defun my/skk-C-j-key (arg)
   (interactive "P")
   (cond
    ((and (null (skk-in-minibuffer-p))
          (null skk-henkan-mode))
     (skk-emulate-original-map arg))
    (t
     (skk-kakutei arg))))

 (with-eval-after-load 'skk
   ;; config
   (setopt skk-preload t)
   (setopt default-input-method "japanese-skk"))

 (with-eval-after-load 'skk-vars
   ;; use skkserv
   (when-darwin
    (setopt skk-server-host "localhost")
    (setopt skk-server-portnum 1178))

   ;; guix
   (when-guix
    (setopt skk-user-directory "~/.my-skk-jisyo"))

   (setopt skk-byte-compile-init-file t)
   (setopt skk-isearch-mode-enable 'always)
   (setopt skk-egg-like-newline t)
   (setopt skk-show-annotation nil)
   (setopt skk-auto-insert-paren t)

   ;; azik
   (setopt skk-use-azik t)
   (setopt skk-azik-keyboard-type 'jp106)

   ;; ref: https://github.com/skk-dev/ddskk/blob/master/etc/dot.skk#L752-L768
   (add-to-list 'skk-rom-kana-rule-list '(skk-kakutei-key nil my/skk-C-j-key))))

(eval-when-compile
  (el-clone :repo "conao3/ddskk-posframe.el"))

(with-delayed-execution
 (message "Install ddskk-posframe...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ddskk-posframe"))

 (autoload-if-found '(ddskk-posframe-mode) "ddskk-posframe" nil t)

 (with-eval-after-load 'skk
   (add-hook 'skk-mode-hook #'ddskk-posframe-mode)))

(eval-when-compile
  (el-clone :repo "dieggsy/emacs-hacker-typer"))

(with-delayed-execution
 (message "Install hacker-typer...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-hacker-typer"))

 (autoload-if-found '(hacker-typer) "hacker-typer" nil t))

(eval-when-compile
  (el-clone :repo "elizagamedev/power-mode.el"))

(with-delayed-execution
 (message "Install power-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/power-mode"))

 (autoload-if-found '(power-mode) "power-mode" nil t))

(eval-when-compile
  (el-clone :repo "yewton/sudden-death.el"))

(with-delayed-execution
 (message "Install sudden-death...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/sudden-death"))

 (autoload-if-found '(sudden-death) "sudden-death" nil t))

(eval-when-compile
  (el-clone :repo "bkaestner/redacted.el"))

(with-delayed-execution
 (message "Install redacted...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/redacted"))

 (autoload-if-found '(redacted-mode) "redacted" nil t)

 (defun my/redacted-mode ()
   (interactive)
   (read-only-mode (if redacted-mode -1 nil))
   (redacted-mode (if redacted-mode -1 1))))

(eval-when-compile
  (el-clone :repo "jschaf/emacs-lorem-ipsum"))

(with-delayed-execution
 (message "Install lorem-ipsum...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-lorem-ipsum"))

 (autoload-if-found '(lorem-ipsum-insert-sentences
                      lorem-ipsum-insert-paragraphs
                      lorem-ipsum-insert-list) "lorem-ipsum" nil t)

 (keymap-global-set "C-c C-l s" #'lorem-ipsum-insert-sentences)
 (keymap-global-set "C-c C-l p" #'lorem-ipsum-insert-paragraphs)
 (keymap-global-set "C-c C-l l" #'lorem-ipsum-insert-list))

(eval-when-compile
  (el-clone :repo "emacsorphanage/key-chord"))

(with-delayed-execution
 (message "Install key-chord...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/key-chord"))

 (autoload-if-found '(key-chord-mode key-chord-define-global) "key-chord" nil t)
 (key-chord-mode 1)

 ;; for global
 (key-chord-define-global "fj" #'view-mode)
 (key-chord-define-global "jf" #'view-mode))

(eval-when-compile
  (el-clone :repo "uk-ar/key-combo"))

(with-delayed-execution
 (message "Install key-combo...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/key-combo"))

 (autoload-if-found '(key-combo-mode key-combo-define-local) "key-combo" nil t)

 ;; for typescript-tsx-mode
 (with-eval-after-load 'typescript-tsx-mode
   (add-hook 'typescript-tsx-mode
             #'(lambda ()
                 (key-combo-mode)
                 (key-combo-define-local (kbd "</") #'web-mode-element-close)))))

(eval-when-compile
  (el-clone :repo "justbur/emacs-which-key"))

(with-delayed-execution
 (message "Install which-key...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-which-key"))

 (autoload-if-found '(which-key-mode) "which-key" nil t)

 (which-key-mode))

(eval-when-compile
  (el-clone :repo "emacs-jp/dmacro"))

(with-delayed-execution
 (message "Install dmacro...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/dmacro"))

 (autoload-if-found '(global-dmacro-mode) "dmacro" nil t)

 (global-dmacro-mode))

(eval-when-compile
  (el-clone :repo "emacsorphanage/god-mode"))

(with-delayed-execution
 (message "Install god-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/god-mode"))
 (autoload-if-found '(god-mode) "god-mode" nil t))

(with-delayed-execution
 (message "Install eglot...")

 (autoload-if-found '(eglot) "eglot" nil t)

 (with-eval-after-load 'eglot
   ;; config
   (setopt eglot-events-buffer-size nil)
   (setopt eglot-autoshutdown t)
   (setopt eglot-extend-to-xref t)))

;; language server
;; (add-to-list 'eglot-server-programs '(php-mode . ("intelephense" "--stdio")))


(eval-when-compile
  (el-clone :repo "emacs-lsp/lsp-mode"
            :load-paths `(,(locate-user-emacs-file "el-clone/lsp-mode/clients"))))

(with-delayed-execution
 (message "Install lsp-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/lsp-mode"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/lsp-mode/clients"))

 (autoload-if-found '(lsp lsp-deferred lsp-org lsp-register-client make-lsp-client) "lsp-mode" nil t)
 (autoload-if-found '(lsp-lens-mode lsp-lens-refresh lsp-lens--enable) "lsp-lens" nil t)
 (autoload-if-found '(lsp-modeline-workspace-status-mode) "lsp-modeline" nil t)
 (autoload-if-found '(lsp-headerline-breadcrumb-mode) "lsp-headerline" nil t)
 (autoload-if-found '(lsp-diagnostics-mode) "lsp-diagnostics" nil t)

 (advice-add 'lsp-rename :before #'(lambda (&rest _) (remove-hook 'find-file-hooks #'view-mode)))
 (advice-add 'lsp-rename :after #'(lambda (&rest _) (add-hook 'find-file-hooks #'view-mode)))

 (with-eval-after-load 'lsp-mode
   ;; ignore path
   (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]vendor")
   (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]storage")
   (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]docs")
   (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]target")
   (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\].calva")
   (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\].clj-kondo")
   (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\].direnv")

   ;; enable flycheck
   (add-hook 'lsp-mode-hook #'flycheck-mode)

   ;; enable diagnostics
   (add-hook 'lsp-configure-hook #'lsp-diagnostics-mode)

   ;; config
   (setopt lsp-idle-delay 0.8)
   (setopt lsp-enable-links nil)
   (setopt lsp-log-io nil)
   (setopt lsp-file-watch-threshold 20000))

 (with-eval-after-load 'lsp-diagnostics
   (setopt lsp-diagnostics-flycheck-default-level 'info))

 (with-eval-after-load 'lsp-completion
   (setopt lsp-completion-no-cache t)
   (setopt lsp-prefer-capf t))

 (with-eval-after-load 'lsp-javascript
   ;; for typescript-language-server
   (setopt lsp-clients-typescript-log-verbosity "info")
   (setopt lsp-typescript-references-code-lens-enabled t)
   (setopt lsp-typescript-implementations-code-lens-enabled t)
   (setopt lsp-javascript-display-return-type-hints t)
   (setopt lsp-javascript-display-parameter-type-hints t)
   (setopt lsp-javascript-display-parameter-name-hints-when-argument-matches-name t)
   (setopt lsp-javascript-display-property-declaration-type-hints t)
   (setopt lsp-javascript-display-variable-type-hints t))

 (with-eval-after-load 'lsp-completion
   (setopt lsp-completion-provider :none))

 (with-eval-after-load 'lsp-ruby
   (setopt lsp-solargraph-autoformat t)
   (setopt lsp-solargraph-multi-root nil))

 (with-eval-after-load 'lsp-nix
   (setopt lsp-nix-nil-formatter '("nixpkgs-fmt"))
   (setopt lsp-nix-nil-max-mem 100000)))

(eval-when-compile
  (el-clone :repo "emacs-lsp/lsp-sourcekit"))

(with-delayed-execution
 (message "Install lsp-sourcekit...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/lsp-sourcekit"))

 (with-eval-after-load 'lsp-mode
   (require 'lsp-sourcekit)))

(eval-when-compile
  (el-clone :repo "emacs-lsp/emacs-ccls"))

(with-delayed-execution
 (message "Install emacs-ccls...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-ccls"))

 (with-eval-after-load 'lsp-mode
   (add-hook 'lsp-mode-hook #'(lambda () (require 'ccls)))))

(eval-when-compile
  (el-clone :repo "gagbo/consult-lsp"))

(with-delayed-execution
 (message "Install consult-lsp...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/consult-lsp"))

 (autoload-if-found '(consult-lsp-symbols) "consult-lsp" nil t)

 (with-eval-after-load 'lsp-mode
   (define-key lsp-mode-map [remap xref-find-apropos] #'consult-lsp-symbols)))

(eval-when-compile
  (el-clone :repo "emacs-lsp/lsp-treemacs"))

(with-delayed-execution
 (message "Install lsp-treemacs...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/lsp-treemacs"))

 (autoload-if-found '(lsp-treemacs-sync-mode) "lsp-treemacs" nil t)

 (with-eval-after-load 'lsp-mode
   (add-hook 'lsp-mode-hook #'lsp-treemacs-sync-mode))

 (with-eval-after-load 'lsp-treemacs
   (setopt lsp-treemacs-error-list-severity 1)
   (setopt lsp-treemacs-error-list-current-project-only t)))

(eval-when-compile
  (el-clone :repo "emacs-lsp/lsp-docker"))

(with-delayed-execution
 (message "Install lsp-docker...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/lsp-docker"))

 (autoload-if-found '(lsp-docker-start) "lsp-docker" nil t))

(eval-when-compile
  (el-clone :repo "emacs-lsp/dap-mode"))

(with-delayed-execution
 (message "Install dap-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/dap-mode"))

 (autoload-if-found '(dap-debug) "dap-mode" nil t)
 (autoload-if-found '(dap-hydra) "dap-hydra" nil t)
 (autoload-if-found '(dap-ui-mode dap-ui-controls-mode) "dap-ui" nil t)
 (autoload-if-found '(dap-tooltip-mode) "dap-mouse" nil t)
 (autoload-if-found '(dap-node-setup) "dap-node" nil t)
 (autoload-if-found '(dap-go-setup) "dap-go" nil t)
 (autoload-if-found '(dap-ruby-setup) "dap-ruby" nil t)

 (with-eval-after-load 'dap-mode
   ;; keybind
   (define-key dap-mode-map (kbd "C-c d") #'dap-breakpoint-toggle)

   ;; hook
   (add-hook 'dap-mode-hook #'dap-ui-mode)
   (add-hook 'dap-mode-hook #'dap-ui-controls-mode)
   (add-hook 'dap-mode-hook #'tooltip-mode)
   (add-hook 'dap-mode-hook #'dap-tooltip-mode)
   (add-hook 'dap-stopped-hook #'(lambda (arg) (call-interactively #'dap-hydra))))

 ;; (with-eval-after-load 'js2-mode
 ;;   (add-hook 'js2-mode-hook #'dap-node-setup))

 (with-eval-after-load 'go-mode
   (add-hook 'go-mode-hook #'dap-go-setup))

 (with-eval-after-load 'ruby-mode
   (add-hook 'ruby-mode-hook #'dap-ruby-setup)))

(eval-when-compile
  (el-clone :repo "emacs-lsp/lsp-ui"))

(with-delayed-execution
 (message "Install lsp-ui...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/lsp-ui"))

 (autoload-if-found '(lsp-ui-mode) "lsp-ui" nil t)

 ;; hook
 (with-eval-after-load 'lsp-mode
   (add-hook 'lsp-mode-hook #'lsp-ui-mode))

 ;; lsp-ui-doc
 (with-eval-after-load 'lsp-ui-doc
   (setopt lsp-ui-doc-enable t)
   (setopt lsp-ui-doc-show-with-cursor t)
   (setopt lsp-ui-doc-use-webkit t)
   (setopt lsp-ui-doc-include-signature t)
   (setopt lsp-ui-doc-delay 1)
   (setopt lsp-ui-doc-max-height 30))

 ;; lsp-ui-peek
 (autoload-if-found '(lsp-ui-peek-find-references lsp-ui-peek-find-definitions lsp-ui-peek-find-implementation) "lsp-ui-peek" nil t)
 (with-eval-after-load 'lsp-ui-peek
   (setopt lsp-ui-peek-enable nil)
   (setopt lsp-ui-peek-peek-height 30)
   (setopt lsp-ui-peek-list-width 60)
   (setopt lsp-ui-peek-fontify 'on-demand))

 ;; lsp-ui-imenu
 (autoload-if-found '(lsp-ui-imenu) "lsp-ui-imenu" nil t)
 (with-eval-after-load 'lsp-ui-imenu
   (setopt lsp-ui-imenu-enable nil)
   (setopt lsp-ui-imenu-kind-position 'top))

 ;; lsp-ui-sideline
 (autoload-if-found '(lsp-ui-sideline-mode) "lsp-ui-sideline" nil t)
 (with-eval-after-load 'lsp-ui-sideline
   (setopt lsp-ui-sideline-enable nil)
   (setopt lsp-ui-sideline-show-hover t))

 ;; keybind
 (with-eval-after-load 'lsp-mode
   (define-key lsp-mode-map (kbd "C-c C-r") #'lsp-ui-peek-find-references)
   (define-key lsp-mode-map (kbd "C-c C-j") #'lsp-ui-peek-find-definitions)
   (define-key lsp-mode-map (kbd "C-c C-i") #'lsp-ui-peek-find-implementation)
   (define-key lsp-mode-map (kbd "C-c C-m") #'lsp-ui-imenu)
   (define-key lsp-mode-map (kbd "C-c C-s") #'lsp-ui-sideline-mode)
   (define-key lsp-mode-map (kbd "C-c C-d") #'lsp-ui-doc-mode)))

(eval-when-compile
  (el-clone :repo "takeokunn/emacs-lsp-scheme"))

(with-delayed-execution
 (message "Install lsp-scheme...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-lsp-scheme"))

 (autoload-if-found '(lsp-scheme) "lsp-scheme" nil t)

 (with-eval-after-load 'scheme)
 ;; (add-hook 'scheme-mode-hook #'lsp-scheme)
 

 (with-eval-after-load 'lsp-scheme
   (setopt lsp-scheme-implementation "guile")))

(eval-when-compile
  (el-clone :repo "emacs-lsp/lsp-haskell"))

(with-delayed-execution
 (message "Install lsp-haskell...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/lsp-haskell"))

 (autoload-if-found '(lsp) "lsp-haskell" nil t)

 (with-eval-after-load 'haskell-mode
   (add-hook 'haskell-mode-hook #'lsp)
   (add-hook 'haskell-literate-mode-hook #'lsp)))

(eval-when-compile
  (el-clone :repo "emacs-lsp/lsp-pyright"))

(with-delayed-execution
 (message "Install lsp-pyright...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/lsp-pyright")))

;; (with-eval-after-load 'python-mode
;;   (add-hook 'python-mode-hook #'(lambda ()
;;                                   (require 'lsp-pyright)
;;                                   (lsp))))

(eval-when-compile
  (el-clone :repo "manateelazycat/lsp-bridge"))

(with-delayed-execution
 (message "Install lsp-bridge...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/lsp-bridge"))

 (autoload-if-found '(lsp-bridge-mode) "lsp-bridge" nil t)

 (with-eval-after-load 'lsp-bridge
   ;; config
   ;; keybind
   (define-key lsp-bridge-mode-map (kbd "M-.") #'lsp-bridge-find-impl)
   (define-key lsp-bridge-mode-map (kbd "C-c C-r") #'lsp-bridge-find-references)))

(eval-when-compile
  (el-clone :repo "lewang/command-log-mode"))

(with-delayed-execution
 (message "Install command-log-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/command-log-mode"))

 (autoload-if-found '(clm/toggle-command-log-buffer) "command-log-mode" nil t)

 (defalias 'command-log #'clm/toggle-command-log-buffer))

(eval-when-compile
  (el-clone :repo "takeokunn/fancy-narrow"))

(with-delayed-execution
 (message "Install fancy-narrow...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/fancy-narrow"))

 (autoload-if-found '(fancy-narrow-mode) "fancy-narrow" nil t))

;; (with-eval-after-load 'org
;;   (add-hook 'org-mode-hook #'fancy-narrow-mode))

;; (with-eval-after-load 'elisp-mode
;;   (add-hook 'emacs-lisp-mode-hook #'fancy-narrow-mode))

;; (with-eval-after-load 'lisp-mode
;;   (add-hook 'lisp-mode-hook #'fancy-narrow-mode))

;; (with-eval-after-load 'clojure-mode
;;   (add-hook 'clojure-mode-hook #'fancy-narrow-mode))

(with-delayed-execution
 (message "Install proced...")
 (autoload-if-found '(proced) "proced" nil t)
 (add-hook 'proced-mode-hook #'(lambda () (proced-toggle-auto-update 1)))
 (with-eval-after-load 'proced
   (setopt proced-auto-update-interval 10)
   (setopt proced-tree-flag t)
   (setopt proced-format 'long)))

(eval-when-compile
  (el-clone :repo "travisjeffery/proced-narrow"))

(with-delayed-execution
 (message "Install proced-narrow...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/proced-narrow"))

 (autoload-if-found '(proced-narrow) "proced-narrow" nil t)

 (with-eval-after-load 'proced
   (define-key proced-mode-map (kbd "/") #'proced-narrow)))

(eval-when-compile
  (el-clone :repo "bbatsov/projectile"))

(with-delayed-execution-priority-high
 (message "Install projectile...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/projectile"))

 (autoload-if-found '(projectile-mode) "projectile" nil t)

 (projectile-mode)

 (defun my/update-projectile-known-projects ()
   (interactive)
   (projectile-clear-known-projects)
   (projectile-cleanup-known-projects)
   (setopt projectile-known-projects (mapcar
                                      (lambda (x)
                                        (abbreviate-file-name (concat x "/")))
                                      (split-string (shell-command-to-string "ghq list --full-path")))))

 (with-eval-after-load 'projectile
   ;; keybind
   (keymap-global-set "M-p" #'projectile-command-map)
   (keymap-global-set "C-c p" #'projectile-command-map)

   ;; hook
   (add-hook 'projectile-mode-hook #'my/update-projectile-known-projects)

   ;; config
   (setopt projectile-switch-project-action 'projectile-dired)
   (setopt projectile-enable-caching t)
   (setopt projectile-use-git-grep t)))

(eval-when-compile
  (el-clone :fetcher "gitlab" :repo "OlMon/consult-projectile"))

(with-delayed-execution
 (message "Install consult-projectile...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/consult-projectile"))

 (autoload-if-found '(consult-projectile-switch-to-buffer
                      consult-projectile-switch-to-buffer-other-window
                      consult-projectile-switch-to-buffer-other-frame
                      consult-projectile-find-dir
                      consult-projectile-find-file
                      consult-projectile-find-file-other-window
                      consult-projectile-find-file-other-frame
                      consult-projectile-recentf
                      consult-projectile-switch-project) "consult-projectile" nil t)

 (with-eval-after-load 'projectile
   (advice-add 'projectile-switch-to-buffer :override #'consult-projectile-switch-to-buffer)
   (advice-add 'projectile-switch-to-buffer-other-window :override #'consult-projectile-switch-to-buffer-other-window)
   (advice-add 'projectile-switch-to-buffer-other-frame :override #'consult-projectile-switch-to-buffer-other-frame)
   (advice-add 'projectile-find-dir :override #'consult-projectile-find-dir)
   (advice-add 'projectile-find-file :override #'consult-projectile-find-file)
   (advice-add 'projectile-find-file-other-window :override #'consult-projectile-find-file-other-window)
   (advice-add 'projectile-find-file-other-frame :override #'consult-projectile-find-file-other-frame)
   (advice-add 'projectile-recentf :override #'consult-projectile-recentf)
   (advice-add 'projectile-switch-project :override #'consult-projectile-switch-project)))

(eval-when-compile
  (el-clone :repo "Wilfred/emacs-refactor"))

(with-delayed-execution
 (message "Install emr...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-refactor"))

 (autoload-if-found '(emr-show-refactor-menu) "emr" nil t)

 (with-eval-after-load 'prog-mode
   (define-key prog-mode-map (kbd "M-RET") #'emr-show-refactor-menu)))

(eval-when-compile
  (el-clone :repo "mhayashi1120/Emacs-wgrep"))

(with-delayed-execution
 (message "Install wgrep...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-wgrep"))

 (autoload-if-found '(wgrep-setup) "wgrep" nil t)

 (with-eval-after-load 'grep
   (add-hook 'grep-setup-hook 'wgrep-setup)))

(eval-when-compile
  (el-clone :repo "minad/consult"))

(with-delayed-execution
 (message "Install consult...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/consult"))

 (autoload-if-found '(consult-bookmark
                      consult-buffer
                      consult-buffer-other-frame
                      consult-buffer-other-tab
                      consult-buffer-other-window
                      consult-complex-command
                      consult-find
                      consult-flycheck
                      consult-focus-lines
                      consult-git-grep
                      consult-global-mark
                      consult-goto-line
                      consult-grep
                      consult-history
                      consult-isearch-history
                      consult-keep-lines
                      consult-line
                      consult-line-multi
                      consult-locate
                      consult-man
                      consult-mark
                      consult-outline
                      consult-project-buffer
                      consult-register
                      consult-register-load
                      consult-register-store
                      consult-ripgrep
                      consult-yank-pop
                      consult-mode-command

                      ;; other
                      consult-preview-at-point-mode
                      consult-register-window) "consult" nil t)
 (autoload-if-found '(consult-compile-error) "consult-compile" nil t)
 (autoload-if-found '(consult-org-heading consult-org-agenda) "consult-org" nil t)
 (autoload-if-found '(consult-imenu consult-imenu-multi) "consult-imenu" nil t)
 (autoload-if-found '(consult-kmacro) "consult-kmacro" nil t)
 (autoload-if-found '(consult-xref) "consult-xref" nil t)

 ;; keybind
 ;; C-c bindings in `mode-specific-map'
 (keymap-global-set "C-c M-x" #'consult-mode-command)
 (keymap-global-set "C-c h" #'consult-history)

 ;; C-x bindings in `ctl-x-map'
 (keymap-global-set "C-x M-:" #'consult-complex-command)
 (keymap-global-set "C-x b" #'consult-buffer)
 (keymap-global-set "C-x 4 b" #'consult-buffer-other-window)
 (keymap-global-set "C-x 5 b" #'consult-buffer-other-frame)

 ;; Other custom bindings
 (keymap-global-set "M-y" #'consult-yank-pop)

 ;; M-g bindings in `goto-map'
 (keymap-global-set "M-g e" #'consult-compile-error)
 (keymap-global-set "M-g f" #'consult-flycheck)
 (keymap-global-set "M-g g" #'consult-goto-line)
 (keymap-global-set "M-g M-g" #'consult-goto-line)
 (keymap-global-set "M-g o" #'consult-outline)
 (keymap-global-set "M-g m" #'consult-mark)
 (keymap-global-set "M-g k" #'consult-global-mark)
 (keymap-global-set "M-g i" #'consult-imenu)
 (keymap-global-set "M-g I" #'consult-imenu-multi)

 ;; C-o bindings in `search-map'
 (keymap-global-set "C-o" #'(lambda ()
                              (interactive)
                              (let ((word (thing-at-point 'symbol 'no-properties)))
                                (consult-line word))))

 ;; Isearch integration
 (with-eval-after-load 'isearch
   (define-key isearch-mode-map (kbd "M-e") #'consult-isearch-history))

 ;; Minibuffer history
 (with-eval-after-load 'minibuffer
   (define-key minibuffer-local-map (kbd "M-s") #'consult-history)
   (define-key minibuffer-local-map (kbd "M-r") #'consult-history))

 (with-eval-after-load 'simple
   (add-hook 'completion-list-mode #'consult-preview-at-point-mode))

 (with-eval-after-load 'register
   (advice-add #'register-preview :override #'consult-register-window))

 (with-eval-after-load 'xref
   (setopt xref-show-xrefs-function #'consult-xref)
   (setopt xref-show-definitions-function #'consult-xref)))

(eval-when-compile
  (el-clone :repo "minad/affe"))

(with-delayed-execution
 (message "Install affe...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/affe"))

 (autoload-if-found '(affe-grep) "affe" nil t)

 (with-eval-after-load 'affe
   (setopt affe-highlight-function 'orderless-highlight-matches)
   (setopt affe-find-command "fd --color=never --full-path")
   (setopt affe-regexp-function 'orderless-pattern-compiler)))

(eval-when-compile
  (el-clone :repo "mohkale/compile-multi"))

(with-delayed-execution
 (message "Install compile-multi...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/compile-multi"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/compile-multi/extensions/consult-compile-multi"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/compile-multi/extensions/compile-multi-embark"))

 (autoload-if-found '(compile-multi) "compile-multi" nil t)
 (autoload-if-found '(consult-compile-multi-mode) "consult-compile-multi" nil t)
 (autoload-if-found '(compile-multi-embark-mode) "compile-multi-embark" nil t)

 (keymap-global-set "C-x m" #'compile-multi)

 (with-eval-after-load 'consult
   (consult-compile-multi-mode))

 (with-eval-after-load 'embark
   (compile-multi-embark-mode)))

(eval-when-compile
  (el-clone :repo "minad/vertico"))

(with-delayed-execution
 (message "Install vertico...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/vertico"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/vertico/extensions"))

 (autoload-if-found '(vertico-mode) "vertico" nil t)
 (autoload-if-found '(vertico-directory-tidy
                      vertico-directory-enter
                      vertico-directory-delete-char
                      vertico-directory-delete-word) "vertico-directory" nil t)
 (autoload-if-found '(vertico-flat-mode) "vertico-flat" nil t)

 (vertico-mode)

 (with-eval-after-load 'rfn-eshadow
   (add-hook 'rfn-eshadow-update-overlay #'vertico-directory-tidy))

 (with-eval-after-load 'vertico
   (setopt vertico-count 8)
   (setopt vertico-cycle t)))

(eval-when-compile
  (el-clone :repo "minad/marginalia"))

(with-delayed-execution
 (message "Install marginalia...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/marginalia"))
 (autoload-if-found '(marginalia-mode) "marginalia" nil t)

 (marginalia-mode)

 (with-eval-after-load 'minibuffer
   (define-key minibuffer-local-map (kbd "M-A") #'marginalia-cycle)))

(eval-when-compile
  (el-clone :repo "oantolin/orderless"))

(with-delayed-execution
 (message "Install orderless...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/orderless"))

 (autoload-if-found '(orderless-all-completions
                      orderless-try-completion) "orderless" nil t)

 (with-eval-after-load 'minibuffer
   (setopt completion-styles '(orderless basic))
   ;; (setopt completion-category-overrides '((file (styles basic partial-completion))))

   (add-to-list 'completion-styles-alist '(orderless orderless-try-completion orderless-all-completions
                                                     "Completion of multiple components, in any order."))))

(eval-when-compile
  (el-clone :repo "purcell/exec-path-from-shell"))

(with-delayed-execution-priority-high
 (message "Install exec-path-from-shell...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/exec-path-from-shell"))

 (autoload-if-found '(exec-path-from-shell-initialize) "exec-path-from-shell")
 (exec-path-from-shell-initialize)

 (with-eval-after-load 'exec-path-from-shell
   (setopt exec-path-from-shell-variables '("PATH"
                                            "GEM_HOME"
                                            "GOROOT"
                                            "GOPATH"
                                            "LSP_USE_PLISTS"
                                            "TERM"
                                            "SSH_AUTH_SOCK"
                                            "NATIVE_FULL_AOT"
                                            "GPG_TTY"))))

(eval-when-compile
  (el-clone :repo "joaotavora/yasnippet"))

(with-delayed-execution
 (message "Install yasnippet...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/yasnippet"))

 (autoload-if-found '(yas-global-mode) "yasnippet" nil t)

 (yas-global-mode 1))

(eval-when-compile
  (el-clone :repo "mohkale/consult-yasnippet"))

(with-delayed-execution
 (message "Install consult-yasnippet...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/consult-yasnippet"))

 (autoload-if-found '(consult-yasnippet) "consult-yasnippet" nil t)

 (keymap-global-set "C-c y" #'consult-yasnippet)
 (keymap-global-set "C-c C-y" #'consult-yasnippet))

(eval-when-compile
  (el-clone :repo "jschaf/esup"))

(with-delayed-execution
 (message "Install esup...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/esup"))

 (autoload-if-found '(esup) "esup" nil t))

(eval-when-compile
  (el-clone :repo "lastquestion/explain-pause-mode"))

(with-delayed-execution
 (message "Install explain-pause-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/explain-pause-mode"))

 (autoload-if-found '(explain-pause-mode) "explain-pause-mode" nil t))

(eval-when-compile
  (el-clone :repo "emacs-straight/disk-usage"))

(with-delayed-execution
 (message "Install disk-usage...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/disk-usage"))

 (autoload-if-found '(disk-usage disk-usage-here) "disk-usage" nil t))

(eval-when-compile
  (el-clone :repo "dacap/keyfreq"))

(with-delayed-execution
 (message "Install keyfreq...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/keyfreq"))

 (autoload-if-found '(keyfreq-mode keyfreq-autosave-mode) "keyfreq" nil t)

 (keyfreq-mode 1)
 (keyfreq-autosave-mode 1))

(eval-when-compile
  (el-clone :repo "davep/uptimes.el"))

(with-delayed-execution
 (message "Install uptimes...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/uptimes"))

 (autoload-if-found '(uptimes) "uptimes" nil t))

(eval-when-compile
  (el-clone :repo "jpkotta/syntax-subword"))

(with-delayed-execution
 (message "Install syntax-subword...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/syntax-subword"))

 (autoload-if-found '(global-syntax-subword-mode) "syntax-subword" nil t)

 (global-syntax-subword-mode))

(eval-when-compile
  (el-clone :repo "zk-phi/symon"))

(with-delayed-execution
 (message "Install symon...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/symon"))

 (autoload-if-found '(symon-mode) "symon" nil t)

 (when-guix
  (symon-mode)))

(with-delayed-execution
 (message "Install tab-bar...")
 (autoload-if-found '(tab-bar-mode
                      tab-bar-history-mode
                      tab-previous
                      tab-next) "tab-bar" nil t)

 (tab-bar-history-mode)

 (keymap-global-set "C-x C-t" tab-prefix-map)
 (keymap-global-set "M-[" #'tab-previous)
 (keymap-global-set "M-]" #'tab-next)

 (with-eval-after-load 'tab-bar
   (setopt tab-bar-close-button-show nil)
   (setopt tab-bar-close-last-tab-choice nil)
   (setopt tab-bar-close-tab-select 'left)
   (setopt tab-bar-history-mode nil)
   (setopt tab-bar-new-tab-choice "*scratch*")
   (setopt tab-bar-new-button-show nil)
   (setopt tab-bar-tab-name-truncated-max 12)
   (setopt tab-bar-separator " | "))

 (defun my/tab-bar-rename-tab ()
   (interactive)
   (let ((proj-name (projectile-project-name)))
     (tab-bar-rename-tab proj-name)))

 ;; rename tab-bar with projectile
 (define-key tab-prefix-map (kbd "r") #'my/tab-bar-rename-tab)

 ;; close neotree when tab bar action
 (advice-add 'tab-new :before #'(lambda (&rest _) (neotree-hide)))
 (advice-add 'tab-next :before #'(lambda (&rest _) (neotree-hide)))
 (advice-add 'tab-bar-switch-to-tab :before #'(lambda (&rest _) (neotree-hide)))

 ;; hook
 (add-hook 'tab-bar-mode-hook #'(lambda () (display-line-numbers-mode -1))))

(with-delayed-execution
 (message "Install autoinsert...")
 (autoload-if-found '(auto-insert-mode) "autoinsert" nil t)

 (auto-insert-mode)

 (with-eval-after-load 'autoinsert
   (setopt auto-insert-directory "~/.emacs.d/auto-insert")))

(eval-when-compile
  (el-clone :repo "rainstormstudio/nerd-icons.el"))

(with-delayed-execution-priority-high
 (message "Install nerd-icons...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/nerd-icons")))

(eval-when-compile
  (el-clone :repo "rainstormstudio/nerd-icons-dired"))

(with-delayed-execution
 (message "Install nerd-icons-dired...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/nerd-icons-dired"))

 (autoload-if-found '(nerd-icons-dired-mode) "nerd-icons-dired" nil t)

 (with-eval-after-load 'dired-mode
   (add-hook 'dired-mode-hook #'nerd-icons-dired-mode)))

(eval-when-compile
  (el-clone :repo "rainstormstudio/nerd-icons-completion"))

(with-delayed-execution
 (message "Install nerd-icons-completion...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/nerd-icons-completion"))

 (autoload-if-found '(nerd-icons-completion-marginalia-setup) "nerd-icons-completion" nil t)

 (nerd-icons-completion-marginalia-setup))

(eval-when-compile
  (el-clone :repo "emacs-dashboard/emacs-dashboard"))

(with-delayed-execution-priority-high
 (message "Install dashboard...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-dashboard"))

 (autoload-if-found '(dashboard-setup-startup-hook) "dashboard" nil t)
 (dashboard-setup-startup-hook)

 (with-eval-after-load 'dashboard
   (setopt dashboard-startup-banner 'logo)
   (setopt dashboard-set-file-icons t)
   (setopt dashboard-startup-banner 4)
   (setopt dashboard-items '((recents . 10)))
   (recentf-load-list)
   (dashboard-refresh-buffer)))


(eval-when-compile
  (el-clone :repo "gonewest818/dimmer.el"))

(with-eval-after-load 'dimmer
  (message "Install dimmer...")
  (add-to-list 'load-path (locate-user-emacs-file "el-clone/dimmer"))

  (autoload-if-found '(dimmer-configure-which-key
                       dimmer-configure-org
                       dimmer-mode)
                     "dimmer" nil t)

  (dimmer-configure-which-key)
  (dimmer-configure-org)
  (dimmer-mode t))

(eval-when-compile
  (el-clone :repo "doomemacs/themes"
            :load-paths `(,(locate-user-emacs-file "el-clone/themes/extensions"))))

(with-delayed-execution-priority-high
 (message "Install doom-themes...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/themes"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/themes/extensions"))

 (autoload-if-found '(doom-themes-enable-org-fontification) "doom-themes-ext-org" nil t)

 (doom-themes-enable-org-fontification)

 (when (require 'doom-themes)
   (load-theme 'doom-challenger-deep t))

 (with-eval-after-load 'doom-themes
   (setopt doom-themes-padded-modeline t)
   (setopt doom-themes-enable-bold t)
   (setopt doom-themes-enable-italic t)))

(eval-when-compile
  (el-clone :repo "seagle0128/doom-modeline"))

(with-delayed-execution-priority-high
 (message "Install doom-modeline...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/doom-modeline"))

 (autoload-if-found '(doom-modeline-mode) "doom-modeline" nil t)

 (doom-modeline-mode 1)
 (line-number-mode 1)
 (column-number-mode 1)

 (with-eval-after-load 'doom-modeline
   (setopt doom-modeline-buffer-file-name-style 'truncate-with-project)
   (setopt doom-modeline-icon `,(display-graphic-p))
   (setopt doom-modeline-major-mode-icon `,(display-graphic-p))
   (setopt doom-modeline-minor-modes nil)))

(with-delayed-execution
 (message "Install hl-line...")
 (autoload-if-found '(global-hl-line-mode) "hl-line-mode" nil t)

 (when (not window-system)
   (global-hl-line-mode))

 (with-eval-after-load 'hl-line
   (set-face-attribute 'hl-line nil :inherit nil)
   (set-face-background 'hl-line "#444642")))

(eval-when-compile
  (el-clone :repo "nonsequitur/idle-highlight-mode"))

(with-delayed-execution
 (message "Install idle-highlight-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/idle-highlight-mode"))

 (autoload-if-found '(idle-highlight-mode) "idle-highlight-mode" nil t)

 (with-eval-after-load 'idle-highlight-mode
   (setopt idle-highlight-idle-time 0.1))

 (with-eval-after-load 'prog-mode
   (add-hook 'prog-mode-hook #'idle-highlight-mode)))

(eval-when-compile
  (el-clone :repo "jaypei/emacs-neotree"))

(with-delayed-execution
 (message "Install neotree...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-neotree"))

 (autoload-if-found '(neotree-hide neotree-dir neotree-make-executor neo-open-file neo-open-dir) "neotree" nil t)

 (defun my/neotree-toggle ()
   (interactive)
   (let ((default-directory (or (locate-dominating-file default-directory ".neotree")
                                (locate-dominating-file default-directory ".git"))))
     (if (and (fboundp 'neo-global--window-exists-p)
              (neo-global--window-exists-p))
         (neotree-hide)
       (neotree-dir default-directory))))

 (keymap-global-set "C-q" #'my/neotree-toggle)

 (with-eval-after-load 'neotree
   ;; config
   (setopt neo-theme 'ascii)
   (setopt neo-show-hidden-files t)

   ;; hook
   (add-hook 'neotree-mode-hook #'(lambda () (display-line-numbers-mode -1)))

   ;; keybind
   (define-key neotree-mode-map (kbd "C-j") (neotree-make-executor
                                             :file-fn #'neo-open-file
                                             :dir-fn  #'neo-open-dir))))

(eval-when-compile
  (el-clone :repo "k-talo/volatile-highlights.el"))

(with-delayed-execution
 (message "Install volatile-highlights...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/volatile-highlights"))

 (autoload-if-found '(volatile-highlights-mode) "volatile-highlights" nil t)

 (volatile-highlights-mode t))

(eval-when-compile
  (el-clone :repo "nonsequitur/idle-highlight-mode"))

(with-delayed-execution
 (message "Install idle-highlight-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/idle-highlight-mode"))

 (autoload-if-found '(idle-highlight-mode) "idle-highlight-mode" nil t)

 (with-eval-after-load 'prog-mode
   (add-hook 'prog-mode-hook #'idle-highlight-mode))

 (with-eval-after-load 'idle-highlight-mode
   (setopt idle-highlight-idle-time 0.1)))

(eval-when-compile
  (el-clone :repo "apchamberlain/undo-tree.el"))

(with-delayed-execution
 (message "Install undo-tree...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/undo-tree"))

 (autoload-if-found '(global-undo-tree-mode) "undo-tree" nil t)

 (global-undo-tree-mode))

(with-delayed-execution
 (message "Install view-mode...")

 (defun my/org-view-next-heading ()
   (interactive)
   (if (and (derived-mode-p 'org-mode)
            (org-at-heading-p))
       (org-next-visible-heading 1)
     (next-line)))

 (defun my/org-view-previous-heading ()
   (interactive)
   (if (and (derived-mode-p 'org-mode)
            (org-at-heading-p))
       (org-previous-visible-heading 1)
     (previous-line)))

 (defun my/view-tab ()
   (interactive)
   (when (and (derived-mode-p 'org-mode)
              (or (org-at-heading-p)
                  (org-at-property-drawer-p)))
     (let ((view-mode nil))
       (org-cycle))))

 (defun my/view-shifttab ()
   (interactive)
   (when (derived-mode-p 'org-mode)
     (let ((view-mode nil))
       (org-shifttab))))

 (defun my/org-edit-special ()
   (interactive)
   (when (derived-mode-p 'org-mode)
     (view-mode -1)
     (org-edit-special)))

 (defun my/org-ctrl-c-ctrl-c ()
   (interactive)
   (when (derived-mode-p 'org-mode)
     (view-mode -1)
     (org-ctrl-c-ctrl-c)))

 (defvar my/view-mode-timer nil)
 (defun my/enable-view-mode-automatically ()
   (if view-mode
       (when my/view-mode-timer
         (cancel-timer my/view-mode-timer))
     (setopt my/view-mode-timer (run-with-idle-timer (* 60 10) nil #'view-mode))))

 (add-hook 'view-mode-hook #'my/enable-view-mode-automatically)
 (advice-add 'view--disable :before #'(lambda (&rest _) (view-lock-mode -1)))

 ;; TODO: Figure out if this actually could be useful
 ;; (with-eval-after-load 'files
 ;;   (add-hook 'find-file-hooks #'view-mode))

 (with-eval-after-load "view"
   (define-key view-mode-map (kbd "f") #'forward-char)
   (define-key view-mode-map (kbd "b") #'backward-char)
   (define-key view-mode-map (kbd "n") #'my/org-view-next-heading)
   (define-key view-mode-map (kbd "p") #'my/org-view-previous-heading)
   (define-key view-mode-map (kbd "@") #'set-mark-command)
   (define-key view-mode-map (kbd "C-c '") #'my/org-edit-special)
   (define-key view-mode-map (kbd "C-c C-C") #'my/org-ctrl-c-ctrl-c)
   (define-key view-mode-map (kbd "e") nil)
   (define-key view-mode-map (kbd "C-j") nil)
   (define-key view-mode-map (kbd "C-i") #'my/view-tab)
   (define-key view-mode-map (kbd "S-C-i") #'my/view-shifttab)))

(eval-when-compile
  (el-clone :repo "s-fubuki/view-lock-mode"))

(with-delayed-execution
 (message "Install view-lock-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/view-lock-mode"))

 (autoload-if-found '(view-lock-timer-start view-lock-quit) "view-lock-mode" nil t)

 (with-eval-after-load 'view
   (add-hook 'view-mode-hook #'view-lock-timer-start))

 (with-eval-after-load 'view-lock-mode
   (setopt view-lock-start-time (* 30 60))))

(eval-when-compile
  (el-clone :repo "zx2c4/password-store"))

(with-delayed-execution
 (message "Install password-store...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/password-store/contrib/emacs")))

(eval-when-compile
  (el-clone :repo "volrath/password-store-otp.el"))

(with-delayed-execution
 (message "Install password-store-otp...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/password-store-otp")))

(eval-when-compile
  (el-clone :repo "NicolasPetton/pass"))

(with-delayed-execution
 (message "Install pass...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/pass"))

 (autoload-if-found '(pass pass-view-mode) "pass" nil t)

 (add-to-list 'auto-mode-alist (cons (substitute-in-file-name "$HOME/ghq/github.com/takeokunn/password-store/.*\\.gpg") 'pass-view-mode))

 (with-eval-after-load 'pass
   (setopt pass-suppress-confirmations t)))

(with-eval-after-load 'comint
  (setopt comint-buffer-maximum-size 100000)
  (setopt comint-prompt-read-only t)
  (setopt comint-terminfo-terminal "eterm-256color"))

(eval-when-compile
  (el-clone :repo "bbatsov/crux"))

(with-delayed-execution
 (message "Install crux...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/crux"))

 (autoload-if-found '(crux-open-with
                      crux-smart-open-line-above
                      crux-cleanup-buffer-or-region
                      crux-view-url
                      crux-transpose-windows
                      crux-duplicate-current-line-or-region
                      crux-duplicate-and-comment-current-line-or-region
                      crux-rename-file-and-buffer
                      crux-visit-term-buffer
                      crux-kill-other-buffers
                      crux-indent-defun
                      crux-top-join-lines
                      crux-kill-line-backwards) "crux" nil t)

 ;; keybind
 (keymap-global-set "C-c o" #'crux-open-with)
 (keymap-global-set "C-S-o" #'crux-smart-open-line-above)
 (keymap-global-set "C-c u" #'crux-view-url)
 (keymap-global-set "C-x 4 t" #'crux-transpose-windows)
 (keymap-global-set "C-c d" #'crux-duplicate-current-line-or-region)
 (keymap-global-set "C-c M-d" #'crux-duplicate-and-comment-current-line-or-region)
 (keymap-global-set "C-c r" #'crux-rename-file-and-buffer)
 (keymap-global-set "C-c M-t" #'crux-visit-term-buffer)
 (keymap-global-set "C-c k" #'crux-kill-other-buffers)
 (keymap-global-set "C-M-z" #'crux-indent-defun)
 (keymap-global-set "C-^" #'crux-top-join-lines)
 (keymap-global-set "C-DEL" #'crux-kill-line-backwards))

(with-delayed-execution
 (message "Install delsel...")
 (autoload-if-found '(delete-selection-mode) "delsel" nil t)
 (delete-selection-mode))

(eval-when-compile
  (el-clone :repo "alphapapa/dogears.el"))

(with-delayed-execution
 (message "Install dogears...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/dogears"))

 (autoload-if-found '(dogears-go
                      dogears-back
                      dogears-forward
                      dogears-list
                      dogears-sidebar) "dogears" nil t)

 ;; keybind
 (keymap-global-set "M-g d" #'dogears-go)
 (keymap-global-set "M-g M-b" #'dogears-back)
 (keymap-global-set "M-g M-f" #'dogears-forward)
 (keymap-global-set "M-g M-d" #'dogears-list)
 (keymap-global-set "M-g M-D" #'dogears-sidebar))

(eval-when-compile
  (el-clone :repo "oantolin/embark"))

(with-delayed-execution
 (message "Install embark...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/embark"))

 (autoload-if-found '(embark-act embark-dwim embark-prefix-help-command) "embark" nil t)
 (autoload-if-found '(embark-consult-outline-candidates
                      embark-consult-imenu-candidates
                      embark-consult-imenu-or-outline-candidates) "embark-consult" nil t)

 (keymap-global-set "C-." #'embark-act)
 (keymap-global-set "C-h B" #'embark-prefix-help-command)

 (defmacro my/embark-ace-action (fn)
   `(defun ,(intern (concat "my/embark-ace-" (symbol-name fn))) ()
      (interactive)
      (with-demoted-errors "%s"
        (aw-switch-to-window (aw-select nil))
        (call-interactively (symbol-function ',fn)))))

 (defmacro my/embark-split-action (fn split-type)
   `(defun ,(intern (concat "my/embark-"
                            (symbol-name fn)
                            "-"
                            (car (last (split-string
                                        (symbol-name split-type) "-"))))) ()
      (interactive)
      (funcall #',split-type)
      (call-interactively #',fn)))

 (defun my/sudo-find-file (file)
   "Open FILE as root."
   (interactive "FOpen file as root: ")
   (when (file-writable-p file)
     (user-error "File is user writeable, aborting sudo"))
   (find-file (if (file-remote-p file)
                  (concat "/" (file-remote-p file 'method) ":"
                          (file-remote-p file 'user) "@" (file-remote-p file 'host)
                          "|sudo:root@"
                          (file-remote-p file 'host) ":" (file-remote-p file 'localname))
                (concat "/sudo:root@localhost:" file))))

 (with-eval-after-load 'embark
   (setopt embark-mixed-indicator-delay 0.1)
   (setopt prefix-help-command #'embark-prefix-help-command)

   ;; ace-window
   (define-key embark-file-map     (kbd "o") (my/embark-ace-action find-file))
   (define-key embark-buffer-map   (kbd "o") (my/embark-ace-action switch-to-buffer))
   (define-key embark-bookmark-map (kbd "o") (my/embark-ace-action bookmark-jump))

   ;; split window(2)
   (define-key embark-file-map     (kbd "2") (my/embark-split-action find-file split-window-below))
   (define-key embark-buffer-map   (kbd "2") (my/embark-split-action switch-to-buffer split-window-below))
   (define-key embark-bookmark-map (kbd "2") (my/embark-split-action bookmark-jump split-window-below))

   ;; split window(3)
   (define-key embark-file-map     (kbd "3") (my/embark-split-action find-file split-window-right))
   (define-key embark-buffer-map   (kbd "3") (my/embark-split-action switch-to-buffer split-window-right))
   (define-key embark-bookmark-map (kbd "3") (my/embark-split-action bookmark-jump split-window-right))

   ;; sudo
   (define-key embark-file-map (kbd "S") #'my/sudo-find-file)

   ;; consult
   (add-hook 'embark-collect-mode-hook #'consult-preview-at-point-mode)))

(with-delayed-execution
 (message "Install goto-addr...")
 (autoload-if-found '(goto-address-prog-mode goto-address-mode) "goto-address" nil t)

 (with-eval-after-load 'prog-mode
   (add-hook 'prog-mode-hook #'goto-address-prog-mode))

 (with-eval-after-load 'text-mode
   (add-hook 'text-mode-hook #'goto-address-mode)))

(eval-when-compile
  (el-clone :repo "hniksic/emacs-htmlize"))

(with-delayed-execution
 (message "Install htmlize...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-htmlize"))

 (with-eval-after-load 'htmlize
   (setopt htmlize-html-charset 'utf-8)))

(with-delayed-execution
 (message "Install midnight...")
 (autoload-if-found '(midnight-mode) "midnight" nil t)
 (midnight-mode)
 (with-eval-after-load 'midnight
   (setopt clean-buffer-list-delay-general 1)))

(eval-when-compile
  (el-clone :repo "AmaiKinono/puni"))

(with-delayed-execution
 (message "Install puni...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/puni"))

 (autoload-if-found '(puni-global-mode puni-disable-puni-mode) "puni" nil t)
 (puni-global-mode)

 (with-eval-after-load 'lisp-mode
   (add-hook 'lisp-mode-hook #'puni-disable-puni-mode))

 (with-eval-after-load 'emacs-lisp-mode
   (add-hook 'emacs-lisp-mode-hook #'puni-disable-puni-mode))

 (with-eval-after-load 'clojure-mode
   (add-hook 'clojure-mode-hook #'puni-disable-puni-mode))

 (with-eval-after-load 'lisp-interaction-mode
   (add-hook 'lisp-interacton-mode-hook #'puni-disable-puni-mode))

 (with-eval-after-load 'scheme
   (add-hook 'scheme-mode-hook #'puni-disable-puni-mode))

 (with-eval-after-load 'simple
   (add-hook 'eval-expression-minibuffer-setup-hook #'puni-disable-puni-mode))

 (with-eval-after-load 'ielm
   (add-hook 'inferior-emacs-lisp-mode-hook #'puni-disable-puni-mode))

 (with-eval-after-load 'minibuffer
   (add-hook 'minibuffer-mode-hook #'puni-disable-puni-mode)))

(eval-when-compile
  (el-clone :repo "emacsorphanage/quickrun"))

(with-delayed-execution
 (message "Install quickrun...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/quickrun"))

 (autoload-if-found '(quickrun) "quickrun" nil t))

(eval-when-compile
  (el-clone :repo "pashky/restclient.el"))

(with-delayed-execution
 (message "Install restclient...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/restclient"))

 (autoload-if-found '(restclient-mode) "restclient" nil t))

(eval-when-compile
  (el-clone :repo "Fuco1/smartparens"))

(with-delayed-execution
 (message "Install smartparens...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/smartparens"))

 (with-eval-after-load 'smartparens))

(eval-when-compile
  (el-clone :repo "jojojames/smart-jump"))

(with-delayed-execution
 (message "Install smart-jump...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/smart-jump"))

 (with-eval-after-load 'smart-jump))

(eval-when-compile
  (el-clone :repo "akicho8/string-inflection"))

(with-delayed-execution
 (message "Install string-inflection...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/string-inflection"))

 (autoload-if-found '(string-inflection-all-cycle) "string-inflection" nil t))

(eval-when-compile
  (el-clone :repo "nflath/sudo-edit"))

(with-delayed-execution
 (message "Install sudo-edit...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/sudo-edit"))

 (autoload-if-found '(sudo-edit) "sudo-edit" nil t))

(eval-when-compile
  (el-clone :repo "alphapapa/topsy.el"))

(with-delayed-execution
 (message "Install topsy...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/topsy"))

 (autoload-if-found '(topsy-mode) "topsy" nil t))
;; (with-eval-after-load 'prog-mode
;;   (add-hook 'prog-mode-hook #'topsy-mode))

;; (with-eval-after-load 'lsp-ui-mode
;;   (add-hook 'lsp-ui-mode-hook #'(lambda () (topsy-mode -1))))

(eval-when-compile
  (el-clone :repo "nicferrier/emacs-uuid"))

(with-delayed-execution
 (message "Install uuid...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-uuid"))

 (autoload-if-found '(uuid-string) "uuid" nil t)

 (defun my/uuid ()
   (interactive)
   (insert (uuid-string)))

 (defalias 'uuid #'my/uuid))

(with-delayed-execution
 (autoload-if-found '(woman woman-find-file) "woman" nil t))

(eval-when-compile
  (el-clone :repo "abo-abo/ace-window"))

(with-delayed-execution
 (message "Install ace-window...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ace-window"))

 (autoload-if-found '(ace-window) "ace-window" nil t)

 (keymap-global-set "C-x o" #'ace-window)

 (with-eval-after-load 'ace-window
   (setopt aw-dispatch-always t)
   (setopt aw-scope 'frame)
   (setopt aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
   (setopt aw-minibuffer-flag t)))

(eval-when-compile
  (el-clone :repo "joostkremers/writeroom-mode"))

(with-delayed-execution
 (message "Install writeroom-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/writeroom-mode"))

 (autoload-if-found '(writeroom-mode
                      writeroom-decrease-width
                      writeroom-increase-width
                      writeroom-adjust-width
                      writeroom-width)
                    "writeroom-mode" nil t)

 (with-eval-after-load 'writeroom-mode
   ;; keybind
   (define-key writeroom-mode-map (kbd "C-M-<") #'writeroom-decrease-width)
   (define-key writeroom-mode-map (kbd "C-M->") #'writeroom-increase-width)
   (define-key writeroom-mode-map (kbd "C-M-=") #'writeroom-adjust-width)

   ;; config
   (setopt writeroom-width 150)
   (setopt writeroom-maximize-window nil)))

(eval-when-compile
  (el-clone :repo "emacsorphanage/zoom-window"))

(with-delayed-execution
 (message "Install zoom-window...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/zoom-window"))

 (autoload-if-found '(zoom-window-zoom) "zoom-window" nil t)

 (keymap-global-set "C-c C-z" #'zoom-window-zoom))

(eval-when-compile
  (el-clone :repo "emacs-pe/docker-tramp.el"))

(with-delayed-execution
 (message "Install docker-tramp...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/docker-tramp"))

 (autoload-if-found '(docker-tramp-add-method) "docker-tramp" nil t)
 (docker-tramp-add-method)

 (with-eval-after-load 'tramp
   (tramp-set-completion-function docker-tramp-method docker-tramp-completion-function-alist)))

(eval-when-compile
  (el-clone :repo "Ladicle/consult-tramp"))

(with-delayed-execution
 (message "Install consult-tramp...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/consult-tramp"))
 (autoload-if-found '(consult-tramp) "consult-tramp" nil t))

(eval-when-compile
  (el-clone :repo "emacsmirror/paredit"))

(with-delayed-execution
 (message "Install paredit...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/paredit"))

 (autoload-if-found '(enable-paredit-mode
                      paredit-forward-slurp-sexp
                      paredit-splice-sexp
                      paredit-define-keys)
                    "paredit" nil t)

 (keymap-global-set "C-c f" #'paredit-forward-slurp-sexp)
 (keymap-global-set "M-s" #'paredit-splice-sexp)

 (with-eval-after-load 'paredit
   (add-hook 'paredit-mode-hook #'paredit-define-keys))

 (with-eval-after-load 'lisp-mode
   (add-hook 'lisp-mode-hook #'enable-paredit-mode)
   (add-hook 'lisp-data-mode-hook #'enable-paredit-mode))

 (with-eval-after-load 'emacs-lisp-mode
   (add-hook 'emacs-lisp-mode-hook #'enable-paredit-mode))

 (with-eval-after-load 'clojure-mode
   (add-hook 'clojure-mode-hook #'enable-paredit-mode))

 (with-eval-after-load 'lisp-interaction-mode
   (add-hook 'lisp-interacton-mode-hook #'enable-paredit-mode))

 (with-eval-after-load 'scheme
   (add-hook 'scheme-mode-hook #'enable-paredit-mode))

 (with-eval-after-load 'simple
   (add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode))

 (with-eval-after-load 'ielm
   (add-hook 'inferior-emacs-lisp-mode-hook #'enable-paredit-mode)))

(eval-when-compile
  (el-clone :repo "Fanael/rainbow-delimiters"))

(with-delayed-execution
 (message "Install rainbow-delimiters...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/rainbow-delimiters"))

 (autoload-if-found '(rainbow-delimiters-mode) "rainbow-delimiters" nil t)

 (add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

 (with-eval-after-load 'lisp-mode
   (add-hook 'lisp-mode-hook #'rainbow-delimiters-mode-enable))

 (with-eval-after-load 'emacs-lisp-mode
   (add-hook 'emacs-lisp-mode-hook #'rainbow-delimiters-mode-enable))

 (with-eval-after-load 'clojure-mode
   (add-hook 'clojure-mode-hook #'rainbow-delimiters-mode-enable))

 (with-eval-after-load 'scheme
   (add-hook 'scheme-mode-hook #'rainbow-delimiters-mode-enable)))

(eval-when-compile
  (el-clone :repo "slime/slime"
            :load-paths `(,(locate-user-emacs-file "el-clone/slime/lib")
                          ,(locate-user-emacs-file "el-clone/slime/contrib")
                          ,(locate-user-emacs-file "el-clone/slime/swank"))))

(with-delayed-execution
 (message "Install slime...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/slime"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/slime/lib"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/slime/contrib"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/slime/swank"))

 (require 'slime)
 (require 'slime-autoloads)

 (load (expand-file-name "$HOME/.roswell/helper.el"))

 (defun my/slime-history ()
   (interactive)
   (if (and (fboundp '-distinct)
            (fboundp 'f-read-text))
       (insert
        (completing-read
         "choice history: "
         (-distinct (read (f-read-text "~/.slime-history.eld")))))))

 (with-eval-after-load 'slime
   (setq slime-net-coding-system 'utf-8-unix))

 (with-eval-after-load 'slime-repl
   (define-key slime-repl-mode-map (kbd "C-c C-r") #'my/slime-history)))

(with-delayed-execution
 (message "Install hyperspec...")
 (autoload-if-found '(hyperspec-lookup) "hyperspec" nil t)

 (with-eval-after-load 'lisp-mode
   (define-key lisp-mode-map (kbd "C-c h") #'hyperspec-lookup)))

(eval-when-compile
  (el-clone :repo "xiongtx/eros"))

(with-delayed-execution
 (message "Install eros...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/eros"))

 (autoload-if-found '(eros-mode) "eros" nil t)

 (with-eval-after-load 'emacs-lisp
   (add-hook 'emacs-lisp-mode-hook #'eros-mode)))

(with-delayed-execution
 (message "Install eldoc...")
 (autoload-if-found '(turn-on-eldoc-mode) "eldoc" nil t)

 (with-eval-after-load 'elisp-mode
   (add-hook 'emacs-lisp-mode-hook #'turn-on-eldoc-mode)
   (add-hook 'lisp-interaction-mode-hook #'turn-on-eldoc-mode))

 (with-eval-after-load 'ielm
   (add-hook 'ielm-mode-hook #'turn-on-eldoc-mode)))

(eval-when-compile
  (el-clone :repo "emacs-elsa/trinary-logic"))

(with-delayed-execution
 (message "Install trinary...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/trinary-logic")))

(eval-when-compile
  (el-clone :repo "emacs-elsa/Elsa"))

(with-delayed-execution
 (message "Install elsa...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/Elsa"))
 (autoload-if-found '(elsa-run) "elsa" nil t))

(eval-when-compile
  (el-clone :repo "emacsmirror/lispxmp"))

(with-delayed-execution
 (message "Install lispxmp...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/lispxmp"))

 (autoload-if-found '(lispxmp) "lispxmp" nil t))

(eval-when-compile
  (el-clone :repo "joddie/macrostep"))

(with-delayed-execution
 (message "Install macrostep...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/macrostep"))

 (autoload-if-found '(macrostep-expand macrostep-mode) "macrostep" nil t)

 (with-eval-after-load 'elisp-mode
   (define-key emacs-lisp-mode-map (kbd "C-c e") #'macrostep-expand)))

(eval-when-compile
  (el-clone :repo "purcell/elisp-slime-nav"))

(with-delayed-execution
 (message "Install eslisp-slime-nav...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/elisp-slime-nav"))

 (autoload-if-found '(elisp-slime-nav-mode) "elisp-slime-nav" nil t)

 (with-eval-after-load 'elisp-mode
   (add-hook 'emacs-lisp-mode-hook #'elisp-slime-nav-mode))

 (with-eval-after-load 'ielm
   (add-hook 'ielm-mode-hook #'elisp-slime-nav-mode)))

(eval-when-compile
  (el-clone :repo "Malabarba/Nameless"))

(with-delayed-execution
 (message "Install nameless...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/Nameless"))

 (autoload-if-found '(nameless-mode) "nameless" nil t)

 (with-eval-after-load 'elisp-mode
   (add-hook 'emacs-lisp-mode-hook #'nameless-mode))

 (with-eval-after-load 'ielm
   (add-hook 'ielm-mode-hook #'nameless-mode)))

(eval-when-compile
  (el-clone :repo "Wilfred/elisp-refs"))

(with-delayed-execution
 (message "Install elisp-refs...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/elisp-refs"))

 (autoload-if-found '(elisp-refs-function
                      elisp-refs-macro
                      elisp-refs-variable
                      elisp-refs-special
                      elisp-refs-symbol) "elisp-refs" nil t))

(eval-when-compile
  (el-clone :repo "Fanael/highlight-quoted"))

(with-delayed-execution
 (message "Install highlight-quoted...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/highlight-quoted"))

 (autoload-if-found '(highlight-quoted-mode) "highlight-quoted" nil t)

 (with-eval-after-load 'elisp-mode
   (add-hook 'emacs-lisp-mode-hook #'highlight-quoted-mode)))

(eval-when-compile
  (el-clone :repo "Fanael/highlight-defined"))

(with-delayed-execution
 (message "Install highlight-defined...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/highlight-defined"))
 (autoload-if-found '(highlight-defined-mode) "highlight-defined" nil t)

 (with-eval-after-load 'elisp-mode
   (add-hook 'emacs-lisp-mode-hook #'highlight-defined-mode)))

(with-delayed-execution
 (when (autoload-if-found '(my/ielm-history) "ielm" nil t))
 (defun my/ielm-history ()
   (interactive)
   (insert
    (completing-read
     "choice history: "
     (progn
       (let ((history nil)
             (comint-input-ring nil))
         (dotimes (index (ring-length comint-input-ring))
           (push (ring-ref comint-input-ring index) history))
         history))))))

(eval-when-compile
  (el-clone :repo "didibus/anakondo"))

(with-delayed-execution
 (message "Install anakondo...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/anakondo"))

 (autoload-if-found '(anakondo-minor-mode) "anakondo" nil t))
;; (with-eval-after-load 'clojure-mode
;;   (add-hook 'clojure-mode-hook #'anakondo-minor-mode)
;;   (add-hook 'clojurescript-mode-hook #'anakondo-minor-mode)
;;   (add-hook 'clojurec-mode-hook #'anakondo-minor-mode))

(eval-when-compile
  (el-clone :repo "brunchboy/kibit-helper"))

(with-delayed-execution
 (message "Install kibit-helper...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/kibit-helper"))

 (autoload-if-found '(kibit kibit-current-file kibit-accept-proposed-change) "kibit-helper" nil t))

;; (autoload-if-found '(clj-refactor-mode cljr-add-keybindings-with-prefix) "clj-refactor" nil t)

;; (add-hook 'clojure-mode-hook #'clj-refactor-mode)
;; (cljr-add-keybindings-with-prefix "C-c C-m")

;; (with-eval-after-load 'clj-refactor
;;   (setopt cljr-suppress-middleware-warnings t)
;;   (setopt cljr-hotload-dependencies t))

(eval-when-compile
  (el-clone :repo "emacsmirror/clang-format"))

(with-delayed-execution
 (message "Install clang-format...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/clang-format"))

 (autoload-if-found '(clang-format-buffer) "clang-format" nil t)

 (add-hook 'before-save-hook #'(lambda ()
                                 (when (member major-mode '(c-mode c++-mode))
                                   (clang-format-buffer)))))

(eval-when-compile
  (el-clone :repo "emacs-vs/rainbow-csv"))

(with-delayed-execution
 (message "Install rainbow-csv...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/rainbow-csv"))

 (autoload-if-found '(rainbow-csv-mode) "rainbow-csv" nil t)

 (with-eval-after-load 'csv-mode
   (add-hook 'csv-mode-hook #'rainbow-csv-mode)))

(eval-when-compile
  (el-clone :repo "abicky/nodejs-repl.el"))

(with-delayed-execution
 (message "Install nodejs-repl...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/nodejs-repl"))

 (autoload-if-found '(nodejs-repl
                      nodejs-repl-send-last-expression
                      nodejs-repl-send-line
                      nodejs-repl-send-region
                      nodejs-repl-send-buffer
                      nodejs-repl-load-file
                      nodejs-repl-switch-to-repl) "nodejs-repl" nil t)

 (with-eval-after-load 'js2-mode
   (define-key js2-mode-map (kbd "C-x C-e") #'nodejs-repl-send-last-expression)
   (define-key js2-mode-map (kbd "C-c C-j") #'nodejs-repl-send-line)
   (define-key js2-mode-map (kbd "C-c C-r") #'nodejs-repl-send-region)
   (define-key js2-mode-map (kbd "C-c C-c") #'nodejs-repl-send-buffer)
   (define-key js2-mode-map (kbd "C-c C-l") #'nodejs-repl-load-file)
   (define-key js2-mode-map (kbd "C-c C-z") #'nodejs-repl-switch-to-repl)))

(eval-when-compile
  (el-clone :repo "js-emacs/js2-refactor.el"))

(with-delayed-execution
 (message "Install js2-refactor...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/js2-refactor"))

 (autoload-if-found '(js2-refactor-mode) "js2-refactor" nil t)

 (with-eval-after-load 'js2-refactor
   (setopt js2r-use-strict t))

 (with-eval-after-load 'js2-mode
   (add-hook 'js2-mode-hook #'js2-refactor-mode))

 (with-eval-after-load 'typescript-mode
   (add-hook 'typescript-mode-hook #'js2-refactor-mode)))

(eval-when-compile
  (el-clone :repo "edmundmiller/emacs-jest"))

(with-delayed-execution
 (message "Install emacs-jest...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-jest"))

 (autoload-if-found '(jest
                      jest-file
                      jest-file-dwim
                      jest-function
                      jest-last-failed
                      jest-repeat
                      jest-minor-mode) "jest" nil t)

 (with-eval-after-load 'typescript-mode
   ;; hook
   (add-hook 'typescript-mode-hook #'jest-minor-mode)

   ;; config
   (setopt jest-executable "npx jest"))

 (with-eval-after-load 'projectile
   (projectile-register-project-type 'npx '("package.json" "yarn.lock")
                                     :project-file "package.json"
                                     :test "npx jest"
                                     :test-suffix ".spec")))

(eval-when-compile
  (el-clone :repo "dgutov/robe"))

(with-delayed-execution
 (message "Install robe...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/robe"))

 (autoload-if-found '(robe-mode inf-ruby-console-auto) "robe" nil t))

(eval-when-compile
  (el-clone :repo "takeokunn/rubocop-emacs"))

(with-delayed-execution
 (message "Install rubocop...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/rubocop-emacs"))

 (autoload-if-found '(rubocop-mode) "rubocop" nil t)

 (with-eval-after-load 'ruby-mode
   ;; config
   (setopt rubocop-keymap-prefix "C-c C-x")

   ;; hook
   (add-hook 'ruby-mode-hook #'rubocop-mode)))

(eval-when-compile
  (el-clone :repo "ajvargo/ruby-refactor"))

(with-delayed-execution
 (message "Install ruby-refactor...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ruby-refactor"))

 (autoload-if-found '(ruby-refactor-mode-launch) "ruby-refactor" nil t)

 (with-eval-after-load 'ruby-mode
   (add-hook 'ruby-mode-hook #'ruby-refactor-mode-launch)))

(eval-when-compile
  (el-clone :repo "nonsequitur/inf-ruby"))

(with-delayed-execution
 (message "Install inf-ruby...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/inf-ruby"))

 (autoload-if-found '(inf-ruby inf-ruby-minor-mode) "inf-ruby" nil t)

 (defun my/irb-history ()
   (interactive)
   (when (and (fboundp '-distinct)
              (fboundp 's-lines)
              (fboundp 'f-read-text))
     (insert
      (completing-read
       "choose history: "
       (mapcar #'list (-distinct (s-lines (f-read-text "~/.irb_history"))))))))

 (with-eval-after-load 'ruby-mode
   (add-hook 'ruby-mode-hook #'inf-ruby-minor-mode)))

(eval-when-compile
  (el-clone :repo "pd/yard-mode.el"))

(with-delayed-execution
 (message "Install yard-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/yard-mode"))

 (autoload-if-found '(yard-mode) "yard-mode" nil t)

 (with-eval-after-load 'ruby-mode
   (add-hook 'ruby-mode-hook #'yard-mode)))

(eval-when-compile
  (el-clone :repo "alex-hhh/emacs-sql-indent"))

(with-delayed-execution
 (message "Install sql-indent...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-sql-indent"))

 (autoload-if-found '(sqlind-setup sqlind-minor-mode) "sql-indent" nil t)

 (with-eval-after-load 'sql
   (add-hook 'sql-mode-hook #'sqlind-setup)
   (add-hook 'sql-mode-hook #'sqlind-minor-mode)))

(eval-when-compile
  (el-clone :repo "polymode/polymode")
  (el-clone :repo "polymode/poly-markdown"))

(with-delayed-execution
 (message "Install polymode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/polymode"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/poly-markdown"))

 (when (autoload-if-found '(poly-markdown-mode) "poly-markdown" nil t)
   (add-to-list 'auto-mode-alist '("\\.md" . poly-markdown-mode))))

(eval-when-compile
  (el-clone :repo "ancane/markdown-preview-mode"))

(with-delayed-execution
 (message "Install markdown-preview-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/markdown-preview-mode"))

 (autoload-if-found '(markdown-preview-open-browser markdown-preview-mode) "markdown-preview-mode" nil t)

 (with-eval-after-load 'markdown-preview-mode
   (setopt markdown-preview-stylesheets (list "http://thomasf.github.io/solarized-css/solarized-light.min.css"))))

(eval-when-compile
  (el-clone :repo "takeokunn/fish-repl.el"))

(with-delayed-execution
 (message "Install fish-repl...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/fish-repl"))

 (autoload-if-found '(fish-repl) "fish-repl" nil t))

(eval-when-compile
  (el-clone :repo "mihaimaruseac/hindent"))

(with-delayed-execution
 (message "Install hindent...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/hindent"))

 (autoload-if-found '(hindent-mode) "hindent" nil t)

 (with-eval-after-load 'haskell-mode
   (add-hook 'haskell-mode-hook #'hindent-mode)))

(eval-when-compile
  (el-clone :repo "smihica/emmet-mode"))

(with-delayed-execution
 (message "Install emmet-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emmet-mode"))

 (autoload-if-found '(emmet-mode) "emmet-mode" nil t)

 (with-eval-after-load 'html-mode
   (add-hook 'html-mode-hook #'emmet-mode))

 (with-eval-after-load 'web-mode
   (add-hook 'web-mode-hook #'emmet-mode))

 (with-eval-after-load 'css-mode
   (add-hook 'css-mode-hook #'emmet-mode))

 (with-eval-after-load 'nxml-mode
   (add-hook 'nxml-mode-hook #'emmet-mode))

 (with-eval-after-load 'typescript-mode
   (add-hook 'typescript-tsx-mode-hook #'emmet-mode))

 (with-eval-after-load 'vue-mode
   (add-hook 'vue-mode-hook #'emmet-mode))

 (with-eval-after-load 'emmet-mode
   (define-key emmet-mode-keymap (kbd "C-j") nil)
   (define-key emmet-mode-keymap (kbd "M-j") #'emmet-expand-line)
   (setopt emmet-self-closing-tag-style "")
   (setopt emmet-indent-after-insert nil)))

(eval-when-compile
  (el-clone :repo "ljos/jq-mode"))

(with-delayed-execution
 (message "Install jq-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/jq-mode"))

 (autoload-if-found '(jq-interactively) "jq-mode" nil t)

 (with-eval-after-load 'json-mode
   (define-key json-mode-map (kbd "C-c C-j") #'jq-interactively)))

(eval-when-compile
  (el-clone :repo "gongo/json-reformat"))

(with-delayed-execution
 (message "Install json-reformat...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/json-reformat"))

 (autoload-if-found '(json-reformat-region) "json-reformat" nil t))

(eval-when-compile
  (el-clone :repo "paetzke/py-isort.el"))

(with-delayed-execution
 (message "Install py-isort...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/py-isort"))

 (autoload-if-found '(py-isort-region
                      py-isort-buffer
                      py-isort-before-save) "py-isort" nil t))

(with-delayed-execution
 (message "Install eshell...")

 ;; configurations
 (with-eval-after-load 'esh-mode
   ;; hook
   (add-hook 'eshell-mode-hook #'(lambda () (display-line-numbers-mode -1)))

   ;; keymap
   (define-key eshell-mode-map (kbd "C-h") #'delete-backward-char)
   (define-key eshell-mode-map (kbd "M-p") #'eshell-previous-matching-input-from-input))

 (with-eval-after-load 'em-cmpl
   (setopt eshell-cmpl-ignore-case t))

 (with-eval-after-load 'em-glob
   (setopt eshell-glob-include-dot-files t)
   (setopt eshell-glob-include-dot-dot nil)
   (setopt eshell-glob-show-progress t))

 (with-eval-after-load 'em-hist
   (setopt eshell-history-size 100000)
   (setopt eshell-hist-ignoredups t))

 (with-eval-after-load 'em-alias
   (setopt eshell-command-aliases-list '(("ll" "ls -la"))))

 (with-eval-after-load 'esh-cmd
   (setopt eshell-prefer-lisp-functions nil))

 (with-eval-after-load 'em-term
   (setopt eshell-destroy-buffer-when-process-dies t)))

(with-delayed-execution
 (message "Install eshell functions...")

 (defun eshell/ff (&rest args)
   "Open a file in Emacs with ARGS, Some habits die hard."
   (if (null args)
       (bury-buffer)
     (mapc #'find-file (mapcar #'expand-file-name (eshell-flatten-list (reverse args))))))

 (defun eshell/unpack (file &rest args)
   "Unpack FILE with ARGS."
   (let ((command (some (lambda (x)
                          (if (string-match-p (car x) file)
                              (cadr x)))
                        '((".*\.tar.bz2" "tar xjf")
                          (".*\.tar.gz" "tar xzf")
                          (".*\.bz2" "bunzip2")
                          (".*\.rar" "unrar x")
                          (".*\.gz" "gunzip")
                          (".*\.tar" "tar xf")
                          (".*\.tbz2" "tar xjf")
                          (".*\.tgz" "tar xzf")
                          (".*\.zip" "unzip")
                          (".*\.Z" "uncompress")
                          (".*" "echo 'Could not unpack the file:'")))))
     (let ((unpack-command(concat command " " file " " (mapconcat 'identity args " "))))
       (eshell/printnl "Unpack command: " unpack-command)
       (eshell-command-result unpack-command))))

 (defun my/cat-with-syntax-highlight (filename)
   "Like cat(1) but with syntax highlighting."
   (let ((existing-buffer (get-file-buffer filename))
         (buffer (find-file-noselect filename)))
     (eshell-print
      (with-current-buffer buffer
        (if (fboundp 'font-lock-ensure)
            (font-lock-ensure)
          (with-no-warnings
            (font-lock-fontify-buffer)))
        (let ((contents (buffer-string)))
          (remove-text-properties 0 (length contents) '(read-only nil) contents)
          contents)))
     (unless existing-buffer
       (kill-buffer buffer))
     nil))

 (advice-add 'eshell/cat :override #'my/cat-with-syntax-highlight))

(with-delayed-execution
 (message "Install eshell prompt...")

 (defun my/eshell-prompt ()
   (concat (abbreviate-file-name (eshell/pwd))
           (if (= (user-uid) 0) " # " " $ ")))

 (with-eval-after-load 'em-prompt
   (setopt eshell-prompt-function #'my/eshell-prompt)))

(eval-when-compile
  (el-clone :repo "ryuslash/eshell-fringe-status"))

(with-delayed-execution
 (message "Install eshell-fringe-status...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/eshell-fringe-status"))

 (autoload-if-found '(eshell-fringe-status-mode) "eshell-fringe-status" nil t)

 (with-eval-after-load 'esh-mode
   (add-hook 'eshell-mode-hook #'eshell-fringe-status-mode)))

(eval-when-compile
  (el-clone :repo "tom-tan/esh-help"))

(with-delayed-execution
 (message "Install esh-help...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/esh-help"))

 (autoload-if-found '(setup-esh-help-eldoc) "esh-help" nil t)

 (setup-esh-help-eldoc))

(eval-when-compile
  (el-clone :repo "takeokunn/eshell-multiple"))

(with-delayed-execution
 (message "Install eshell-multiple...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/eshell-multiple"))

 (autoload-if-found '(eshell-multiple-new
                      eshell-multiple-next
                      eshell-multiple-prev
                      eshell-multiple-clear-buffer
                      eshell-multiple-switch-buffer
                      eshell-multiple-dedicated-toggle
                      eshell-multiple-dedicated-open
                      eshell-multiple-dedicated-close)
                    "eshell-multiple" nil t)

 (defalias 'eshell/new #'eshell-multiple-new)
 (defalias 'eshell/next #'eshell-multiple-next)
 (defalias 'eshell/prev #'eshell-multiple-prev)
 (defalias 'eshell/clear #'eshell-multiple-clear-buffer)

 (with-eval-after-load 'esh-mode
   (define-key eshell-mode-map (kbd "C-l") #'eshell-multiple-clear-buffer)))

(eval-when-compile
  (el-clone :repo "xuchunyang/eshell-z"))

(with-delayed-execution
 (message "Install eshell-z...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/eshell-z"))

 (autoload-if-found '(eshell-z) "eshell-z" nil t)

 (with-eval-after-load 'esh-mode
   (define-key eshell-mode-map (kbd "C-c C-q") #'eshell-z)))

(eval-when-compile
  (el-clone :repo "xuchunyang/eshell-did-you-mean"))

(with-delayed-execution
 (message "Install eshell-did-you-mean...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/eshell-did-you-mean"))

 (autoload-if-found '(eshell-did-you-mean-setup) "eshell-did-you-mean" nil t)

 (with-eval-after-load 'esh-mode
   (add-hook 'eshell-mode-hook #'eshell-did-you-mean-setup)))

(eval-when-compile
  (el-clone :repo "akreisher/eshell-syntax-highlighting"))

(with-delayed-execution
 (message "Install eshell-syntax-highlighting...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/eshell-syntax-highlighting"))

 (autoload-if-found '(eshell-syntax-highlighting-global-mode) "eshell-syntax-highlighting" nil t)

 (eshell-syntax-highlighting-global-mode))

(eval-when-compile
  (el-clone :repo "Ambrevar/emacs-fish-completion"))

(with-delayed-execution
 (message "Install emacs-fish-completion")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-fish-completion"))

 (autoload-if-found '(global-fish-completion-mode) "fish-completion" nil t)

 (when (executable-find "fish")
   (global-fish-completion-mode)))

(eval-when-compile
  (el-clone :url "https://codeberg.org/akib/emacs-eat.git"
            :repo "emacs-eat"))

(with-delayed-execution
 (message "Install emacs-eat...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/emacs-eat"))
 (autoload-if-found '(eat) "eat" nil t))

(eval-when-compile
  (el-clone :repo "szermatt/mistty"))

(with-delayed-execution
 (message "Install mistty...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/mistty"))
 (autoload-if-found '(mistty) "mistty" nil t))

(when my/enable-org-load
  (load (locate-user-emacs-file "extras/org-load.el")))

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

(defun my/beginning-of-intendation ()
  "move to beginning of line, or indentation"
  (interactive)
  (back-to-indentation))

(defun my/copy-buffer ()
  (interactive)
  (save-excursion
    (mark-whole-buffer)
    (copy-region-as-kill (region-beginning) (region-end))))

(defalias 'copy-buffer 'my/copy-buffer)

(defun my/ghq-get ()
  (interactive)
  (let ((url (read-string "url > ")))
    (message
     (shell-command-to-string
      (mapconcat #'shell-quote-argument
                 (list "ghq" "get" url)
                 " ")))))

(defalias 'ghq-get 'my/ghq-get)

(defun my/gh-browse ()
  (interactive)
  (message
   (shell-command-to-string
    (mapconcat #'shell-quote-argument
               (list "gh" "browse")
               " "))))

(defalias 'gh-browse 'my/gh-browse)

(defun my/indent-buffer ()
  (interactive)
  (save-excursion
    (mark-whole-buffer)
    (untabify (region-beginning) (region-end))
    (indent-region (region-beginning) (region-end))))

(defalias 'indent-buffer 'my/indent-buffer)

(defun my/move-line (arg)
  (interactive)
  (let ((col (current-column)))
    (unless (eq col 0)
      (move-to-column 0))
    (save-excursion
      (forward-line)
      (transpose-lines arg))
    (forward-line arg)))

(defun my/move-line-down ()
  (interactive)
  (my/move-line 1))

(defun my/move-line-up ()
  (interactive)
  (my/move-line -1))

(keymap-global-set "M-N" #'my/move-line-down)
(keymap-global-set "M-P" #'my/move-line-up)

(defun my/reload-major-mode ()
  "Reload current major mode."
  (interactive)
  (let ((current-mode major-mode))
    (fundamental-mode)
    (funcall current-mode)
    current-mode))

(defvar my/kill-emacs-keybind-p t)

(defun my/toggle-kill-emacs ()
  (interactive)
  (if my/kill-emacs-keybind-p
      (progn
        (message "C-x C-c save-buffers-kill-emacs OFF")
        (setq my/kill-emacs-keybind-p nil)
        (keymap-global-set "C-x C-c" nil))
    (progn
      (message "C-x C-c save-buffers-kill-emacs ON")
      (setq my/kill-emacs-keybind-p t)
      (keymap-global-set "C-x C-c" 'save-buffers-kill-emacs))))

(defun my/get-class-name-by-file-name ()
  (interactive)
  (insert
   (file-name-nondirectory
    (file-name-sans-extension (or (buffer-file-name)
                                  (buffer-name (current-buffer)))))))

(defun my/insert-clipboard (arg)
  (interactive "sstring: ")
  (kill-new arg))

(defun my/actionlint ()
  (interactive)
  (shell-command-to-string "actionlint"))

(defalias 'actionlint 'my/actionlint)

(defun my/build-info ()
  "Display build information in a buffer."
  (interactive)
  (switch-to-buffer (get-buffer-create "*Build info*"))
  (setq tab-width 4)
  (let ((buffer-read-only nil))
    (erase-buffer)
    (insert (format "GNU Emacs %s\nCommit:\t\t%s\nBranch:\t\t%s\n"
                    emacs-version
                    emacs-repository-version
                    emacs-repository-branch))
    (insert (format "System:\t\t%s\nDate:\t\t%s\n"
                    system-configuration
                    (format-time-string "%Y-%m-%d %T (%Z)" emacs-build-time)))
    (insert (format "Patch:\t\t%s ns-inline.patch\n"
                    (if (boundp 'mac-ime--cursor-type) "with" "without")))
    (insert (format "Features:\t%s\n" system-configuration-features))
    (view-mode)))

(defun my/current-ip-address ()
  (interactive)
  (insert
   (shell-command-to-string "curl -s ifconfig.me")))

(defun my/today ()
  (interactive)
  (insert
   (format-time-string "%Y-%m-%d %a" (current-time))))

(defalias 'today 'my/today)

;; (eval-when-compile
;;   (el-clone-byte-compile))

(setq file-name-handler-alist my/saved-file-name-handler-alist)

(when my/enable-profile
  (profiler-report)
  (profiler-stop))
