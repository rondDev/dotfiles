;;; extras/org-load.el -*- lexical-binding: t; -*-

;;; Code:
(with-eval-after-load 'org
  ;; keybind
  (define-key org-mode-map (kbd "C-c ,") #'org-insert-structure-template)
  (define-key org-mode-map (kbd "C-c C-,") #'org-insert-structure-template)

  ;; directory
  (setopt org-directory "~/org")

  ;; todo
  (setopt org-todo-keywords '((sequence "TODO(t)" "SOMEDAY(s)" "WAIT(w)" "|" "DONE(d)")))

  ;; startup
  (setopt org-startup-folded 'show3levels)
  (setopt org-startup-truncated nil)
  (setopt org-src-window-setup 'current-window)

  ;; archive
  (advice-add 'org-archive-subtree :before #'(lambda (&rest _) (remove-hook 'find-file-hooks #'view-mode)))
  (advice-add 'org-archive-subtree :after #'(lambda (&rest _) (add-hook 'find-file-hooks #'view-mode)))

  (defvar my/org-agenda-files `(,(concat org-directory "/agenda")
                                ,(concat org-directory "/archive/2023")
                                ,(concat org-directory "/archive/2024")))

  (setopt org-agenda-files my/org-agenda-files)
  (setopt org-archive-location `,(format (expand-file-name "archive/%s/%s.org::* Archived Tasks" org-directory)
                                         (format-time-string "%Y" (current-time))
                                         (format-time-string "%Y-%m-%d" (current-time))))

  ;; log
  (setopt org-log-into-drawer t)
  (setopt org-log-done 'time)

  (defun my/update-org-agenda-files ()
    (interactive)
    (setopt org-agenda-files my/org-agenda-files)))

(with-eval-after-load 'org-clock
  (add-hook 'org-mode-hook #'org-clock-load)
  (add-hook 'kill-emacs-hook #'org-clock-save)

  (setopt org-clock-out-remove-zero-time-clocks t)
  (setopt org-clock-clocked-in-display 'mode-line))

(with-eval-after-load 'org-list
  (setopt org-list-allow-alphabetical t))

(with-eval-after-load 'org-keys
  (setopt org-use-extra-keys t)
  (setopt org-use-speed-commands t)

  (add-to-list 'org-speed-commands '("d" org-todo "DONE"))
  (add-to-list 'org-speed-commands '("j" call-interactively #'consult-org-heading)))

(with-delayed-execution
 (autoload-if-found '(org-capture) "org-capture" nil t)
 (keymap-global-set "C-c c" #'org-capture)

 (advice-add 'org-capture :before #'(lambda (&rest _) (remove-hook 'find-file-hooks #'view-mode)))
 (advice-add 'org-capture :after #'(lambda (&rest _) (add-hook 'find-file-hooks #'view-mode)))

 (with-eval-after-load 'org-capture
   (setopt org-capture-use-agenda-date t)
   (setopt org-capture-bookmark nil)
   (setopt org-capture-templates `(("t" "Todo" entry (file ,(expand-file-name "todo.org" org-directory))
                                    "* %?")
                                   ("m" "Memo" entry (file ,(expand-file-name "memo.org" org-directory))
                                    "* %?")
                                   ("j" "Journal" entry (file+olp+datetree ,(expand-file-name "journal.org" org-directory))
                                    "* %U\n%?\n%i\n")))))

(with-eval-after-load 'org-duration
  (setopt org-duration-format (quote h:mm)))

(with-delayed-execution
 (message "Install org-id...")

 (autoload-if-found '(org-id-store-link) "org-id" nil t)

 (with-eval-after-load 'org-id
   (setopt org-id-locations-file (expand-file-name ".org-id-locations" org-directory))
   (setopt org-id-extra-files (append org-agenda-text-search-extra-files))))

(with-delayed-execution
 (autoload-if-found '(org-encrypt-entry org-decrypt-entry org-crypt-use-before-save-magic) "org-crypt" nil t)

 (org-crypt-use-before-save-magic)

 (with-eval-after-load 'org-crypt
   (setopt org-crypt-key nil)
   (setopt org-tags-exclude-from-inheritance '("crypt"))))

(with-delayed-execution
 (autoload-if-found '(orgtbl-mode org-table-begin org-table-end) "org-table" nil t)

 (defun my/org-table-align-markdown ()
   "Replace \"+\" sign with \"|\" in org-table."
   (when (member major-mode '(markdown-mode))
     (save-excursion
       (save-restriction
         (narrow-to-region (org-table-begin) (org-table-end))
         (goto-char (point-min))
         (while (search-forward "-+-" nil t)
           (replace-match "-|-"))))))

 (advice-add 'org-table-align :before #'my/org-table-align-markdown))

(eval-when-compile
  (el-clone :repo "bastibe/org-journal"))

(with-delayed-execution
 (message "Install org-journal...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-journal"))

 (with-eval-after-load 'org-journal
   (setopt org-journal-dir (expand-file-name "journal" org-directory))
   (setopt org-journal-start-on-weekday 7)
   (setopt org-journal-prefix-key "C-c j")))

(eval-when-compile
  (el-clone :repo "conao3/org-generate.el"))

(with-delayed-execution
 (message "Install org-generate...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-generate"))

 (autoload-if-found '(org-generate) "org-generate" nil t))

(eval-when-compile
  (el-clone :repo "marcinkoziej/org-pomodoro"))

(with-delayed-execution
 (message "Install org-pomodoro...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-pomodoro"))

 (autoload-if-found '(org-pomodoro) "org-pomodoro" nil t))

(eval-when-compile
  (el-clone :repo "amno1/org-view-mode"))

(with-delayed-execution
 (message "Install org-view-mode...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-view-mode"))

 (autoload-if-found '(org-view-mode) "org-view-mode" nil t))

(eval-when-compile
  (el-clone :repo "unhammer/org-random-todo"))

(with-delayed-execution
 (message "Install org-random-todo...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-random-todo"))

 (autoload-if-found '(org-random-todo org-random-todo-goto-current) "org-random-todo" nil t))

(eval-when-compile
  (el-clone :repo "IvanMalison/org-projectile"))

(with-delayed-execution
 (message "Install org-projectile...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-projectile"))

 (autoload-if-found '(org-projectile-todo-files
                      org-projectile-project-todo-completing-read)
                    "org-projectile" nil t)

 (keymap-global-set "C-c n p" #'org-projectile-project-todo-completing-read)

 (with-eval-after-load 'org
   (setopt org-agenda-files (append org-agenda-files (org-projectile-todo-files)))))

(eval-when-compile
  (el-clone :repo "bard/org-dashboard"))

(with-delayed-execution
 (message "Install org-dashboard...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-dashboard"))

 (autoload-if-found '(org-dashboard-display) "org-dashboard" nil t))

(eval-when-compile
  (el-clone :repo "akirak/org-volume"))

(with-delayed-execution
 (message "Install org-volume...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-volume"))

 (autoload-if-found '(org-volume-update-entry-from-dblock) "org-volume" nil t))

(eval-when-compile
  (el-clone :repo "alphapapa/org-ql"))

(with-delayed-execution
 (message "Install org-ql...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-ql")))

;; (autoload-if-found '(org-ql-query org-ql-select) "org-ql" nil t)

(with-eval-after-load 'org-faces
  (setopt org-link '(t (:foreground "#ebe087" :underline t))))

(eval-when-compile
  (el-clone :repo "integral-dw/org-superstar-mode"))

(with-delayed-execution
 (message "Install org-superstar...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-superstar-mode"))

 (autoload-if-found '(org-superstar-mode) "org-superstar")

 (with-eval-after-load 'org
   (add-hook 'org-mode-hook #'org-superstar-mode))

 (with-eval-after-load 'org-superstar
   (setopt org-superstar-headline-bullets-list '("◉" "○" "✸" "✿"))
   (setopt org-superstar-leading-bullet " ")))

(eval-when-compile
  (el-clone :repo "snosov1/toc-org"))

(with-delayed-execution
 (message "Install toc-org...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/toc-org"))

 (autoload-if-found '(toc-org-mode) "toc-org" nil t)

 (with-eval-after-load 'org
   ;; hook
   (add-hook 'org-mode-hook #'toc-org-mode)))

(eval-when-compile
  (el-clone :repo "takaxp/org-tree-slide"))

(with-delayed-execution
 (message "Install org-tree-slide...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-tree-slide"))

 (autoload-if-found '(org-tree-slide-mode org-tree-slide-skip-done-toggle) "org-tree-slide" nil t)

 (with-eval-after-load 'org-tree-slide
   (setopt org-tree-slide-skip-outline-level 4)))

(with-delayed-execution
 (message "Install ol...")

 (autoload-if-found '(org-store-link) "ol" nil t)

 (keymap-global-set "C-c l" #'org-store-link)

 (with-eval-after-load 'ol
   (setopt org-link-file-path-type 'relative)))

(eval-when-compile
  (el-clone :repo "emacsmirror/org-link-beautify"))

(with-delayed-execution
 (message "Install org-link-beautify...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-link-beautify"))

 (autoload-if-found '(org-link-beautify-mode) "org-link-beautify" nil t))

;; (with-eval-after-load 'org
;;   (add-hook 'org-mode-hook #'org-link-beautify-mode))

(eval-when-compile
  (el-clone :repo "magit/orgit"))

(with-delayed-execution
 (message "Install orgit...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/orgit"))

 (autoload-if-found '(orgit-store-link) "orgit" nil t)

 (with-eval-after-load 'magit
   (define-key magit-mode-map [remap org-store-link] #'orgit-store-link)))

(with-delayed-execution
 (message "Install org-agenda...")
 (autoload-if-found '(org-agenda) "org-agenda" nil t)

 (keymap-global-set "C-c a" #'org-agenda)

 (with-eval-after-load 'org-agenda
   (setopt org-agenda-span 'day)
   (setopt org-agenda-start-on-weekday 1)
   (setopt org-agenda-todo-ignore-with-date t)))

(eval-when-compile
  (el-clone :repo "alphapapa/org-super-agenda"))

(with-delayed-execution
 (message "Install org-super-agenda...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-super-agenda"))

 (autoload-if-found '(org-super-agenda-mode) "org-super-agenda" nil t)

 (org-super-agenda-mode)

 (with-eval-after-load 'org-super-agenda
   (setopt org-super-agenda-groups '((:log t)
                                     (:auto-group t)
                                     (:name "Today List..." :scheduled today)
                                     (:name "Due Today List..." :deadline today)
                                     (:name "Overdue List..." :deadline past)
                                     (:name "Due Soon List" :deadline future)
                                     (:name "TODO List..." :todo "TODO")
                                     (:name "WAIT List..." :todo "WAIT")
                                     (:name "DONE List..." :todo "DONE")
                                     (:name "SOMEDAY List..." :todo "SOMEDAY")))))

(eval-when-compile
  (el-clone :repo "dmitrym0/org-hyperscheduler"))

(with-delayed-execution
 (message "Install org-hyperscheduler...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-hyperscheduler"))

 (autoload-if-found '(org-hyperscheduler-open) "org-hyperscheduler" nil t))

(eval-when-compile
  (el-clone :repo "ichernyshovvv/org-timeblock"))

(with-delayed-execution
 (message "Install org-timeblock...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-timeblock"))
 (autoload-if-found '(org-timeblock-list org-timeblock-mode) "org-timeblock" nil t))

(with-delayed-execution
 (message "Install ob-babel...")
 (autoload-if-found '(org-babel-do-load-languages) "org" nil t)

 (with-eval-after-load 'ob-core
   (setopt org-confirm-babel-evaluate nil)

   (add-to-list 'org-babel-default-header-args '(:results . "output")))

 (with-eval-after-load 'ob-eval
   (advice-add #'org-babel-eval-error-notify
               :around #'(lambda (old-func &rest args)
                           (when (not (string= (nth 1 args)
                                               "mysql: [Warning] Using a password on the command line interface can be insecure.\n"))
                             (apply old-func args)))))

 (org-babel-do-load-languages 'org-babel-load-languages
                              '((awk . t)
                                (C . t)
                                (R . t)
                                (when (locate-library 'cider) (clojure . t))
                                (emacs-lisp . t)
                                (haskell . t)
                                (java . t)
                                (js . t)
                                (lisp . t)
                                (makefile . t)
                                (perl . t)
                                (plantuml . t)
                                (python . t)
                                (ruby . t)
                                (scheme . t)
                                (shell . t)
                                (sql . t)
                                (shell . t))))

(eval-when-compile
  (el-clone :repo "astahlman/ob-async"))

(with-delayed-execution
 (message "Install ob-async...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ob-async"))

 (autoload-if-found '(ob-async-org-babel-execute-src-block) "ob-async" nil t))

;; (advice-add 'org-babel-execute-src-block :around #'ob-async-org-babel-execute-src-block)

(eval-when-compile
  (el-clone :repo "takeokunn/ob-fish"))

(with-delayed-execution
 (message "Install ob-fish...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ob-fish"))

 (autoload-if-found '(org-babel-execute:fish) "ob-fish" nil t)

 (with-eval-after-load 'org-src
   (add-to-list 'org-src-lang-modes '("fish" . fish))))

(eval-when-compile
  (el-clone :repo "micanzhang/ob-rust"))

(with-delayed-execution
 (message "Install ob-rust...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ob-rust"))

 (autoload-if-found '(org-babel-execute:rust) "ob-rust" nil t)

 (with-eval-after-load 'org-src
   (add-to-list 'org-src-lang-modes '("rust" . rust))))

(eval-when-compile
  (el-clone :repo "pope/ob-go"))

(with-delayed-execution
 (message "Install ob-go...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ob-go"))

 (autoload-if-found '(org-babel-execute:go) "ob-go" nil t)

 (with-eval-after-load 'org-src
   (add-to-list 'org-src-lang-modes '("go" . go))))

(eval-when-compile
  (el-clone :repo "krisajenkins/ob-translate"))

(with-delayed-execution
 (message "Install ob-translate...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ob-translate"))

 (autoload-if-found '(ob-translate:google-translate) "ob-translate" nil t)

 (with-eval-after-load 'text-mode
   (define-derived-mode translate-mode text-mode "translate"))

 (with-eval-after-load 'org-src
   (add-to-list 'org-src-lang-modes '("translate" . translate))))

(eval-when-compile
  (el-clone :repo "lurdan/ob-typescript"))

(with-delayed-execution
 (message "Install ob-typescript...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ob-typescript"))

 (autoload-if-found '(org-babel-execute:typescript) "ob-typescript" nil t)

 (with-eval-after-load 'org-src
   (add-to-list 'org-src-lang-modes '("typescript" . typescript))))

(eval-when-compile
  (el-clone :repo "zweifisch/ob-http"))

(with-delayed-execution
 (message "Install ob-http...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ob-http"))

 (autoload-if-found '(org-babel-execute:http) "ob-http" nil t)
 (autoload-if-found '(ob-http-mode) "ob-http-mode" nil t)

 (with-eval-after-load 'org-src
   (add-to-list 'org-src-lang-modes '("http" . ob-http))))

(eval-when-compile
  (el-clone :repo "arnm/ob-mermaid"))

(with-delayed-execution
 (message "Install ob-mermaid...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ob-mermaid"))

 (autoload-if-found '(org-babel-execute:mermaid) "ob-mermaid" nil t)

 (with-eval-after-load 'org-src
   (add-to-list 'org-src-lang-modes '("mermaid" . mermaid))))

(eval-when-compile
  (el-clone :repo "jdormit/ob-graphql"))

(with-delayed-execution
 (message "Install ob-graphql...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ob-graphql"))
 (autoload-if-found '(org-babel-execute:graphql) "ob-graphql" nil t)

 (with-eval-after-load 'org-src
   (add-to-list 'org-src-lang-modes '("graphql" . graphql))))

(eval-when-compile
  (el-clone :repo "micanzhang/ob-rust"))

(with-delayed-execution
 (message "Install ob-rust...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ob-rust"))
 (autoload-if-found '(org-babel-execute:rust) "ob-rust" nil t)

 (with-eval-after-load 'org-src
   (add-to-list 'org-src-lang-modes '("rust" . rust))))

(eval-when-compile
  (el-clone :repo "zweifisch/ob-swift"))

(with-delayed-execution
 (message "Install ob-swift...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ob-swift"))
 (autoload-if-found '(org-babel-execute:swift) "ob-swift" nil t)

 (with-eval-after-load 'org-src
   (add-to-list 'org-src-lang-modes '("swift" . swift))))

(eval-when-compile
  (el-clone :repo "zweifisch/ob-elixir"))

(with-delayed-execution
 (message "Install ob-elixir...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ob-elixir"))
 (autoload-if-found '(org-babel-execute:elixir) "ob-elixir" nil t)

 (with-eval-after-load 'org-src
   (add-to-list 'org-src-lang-modes '("elixir" . elixir))))

(eval-when-compile
  (el-clone :repo "mzimmerm/ob-dart"))

(with-delayed-execution
 (message "Install ob-dart...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ob-dart"))
 (autoload-if-found '(org-babel-execute:dart) "ob-dart" nil t)

 (with-eval-after-load 'org-src
   (add-to-list 'org-src-lang-modes '("dart" . dart))))

(eval-when-compile
  (el-clone :repo "juergenhoetzel/ob-fsharp"))

(with-delayed-execution
 (message "Install ob-fsharp...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ob-fsharp"))
 (autoload-if-found '(org-babel-execute:fsharp) "ob-fsharp" nil t)

 (with-eval-after-load 'org-src
   (add-to-list 'org-src-lang-modes '("fsharp" . fsharp))))

(eval-when-compile
  (el-clone :repo "takeokunn/ob-treesitter"))

(with-delayed-execution
 (message "Install ob-treesitter...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ob-treesitter"))

 (autoload-if-found '(org-babel-execute:treesitter) "ob-treesitter" nil t)

 (with-eval-after-load 'prog-mode
   (define-derived-mode treesitter-mode prog-mode "treesitter"))

 (with-eval-after-load 'org-src
   (add-to-list 'org-src-lang-modes '("treesitter" . treesitter))))

(eval-when-compile
  (el-clone :repo "KeyWeeUsr/ob-base64"))

(with-delayed-execution
 (message "Install ob-base64...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ob-base64"))

 (autoload-if-found '(org-babel-execute:base64) "ob-base64" nil t)

 (with-eval-after-load 'org-src
   (add-to-list 'org-src-lang-modes '("base64" . base64))))

(eval-when-compile
  (el-clone :repo "AntonHakansson/org-nix-shell"))

(with-delayed-execution
 (message "Install org-nix-shell...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-nix-shell"))

 (autoload-if-found '(org-nix-shell-mode) "org-nix-shell" nil t)

 (with-eval-after-load 'org
   (add-hook 'org-mode-hook #'org-nix-shell-mode)))

(with-eval-after-load 'ox-html
  (setopt org-html-head-include-default-style nil)
  (setopt org-html-head-include-scripts nil)
  (setopt org-html-doctype "html5")
  (setopt org-html-coding-system 'utf-8-unix))

(eval-when-compile
  (el-clone :repo "larstvei/ox-gfm"))

(with-delayed-execution
 (message "Install ox-gfm...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ox-gfm"))

 (autoload-if-found '(org-gfm-export-as-markdown
                      org-gfm-convert-region-to-md
                      org-gfm-export-to-markdown
                      org-gfm-publish-to-gfm) "ox-gfm" nil t))

(eval-when-compile
  (el-clone :repo "conao3/ox-zenn.el"))

(with-delayed-execution
 (message "Install ox-zenn...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ox-zenn"))

 (autoload-if-found '(org-zenn-export-as-markdown
                      org-zenn-export-to-markdown
                      org-zenn-publish-to-markdown
                      org-zenn-convert-region-to-md) "ox-zenn" nil t))

(eval-when-compile
  (el-clone :repo "zonkyy/ox-hatena"))

(with-delayed-execution
 (message "Install ox-hatena...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ox-hatena"))

 (autoload-if-found '(org-hatena-export-as-hatena
                      org-hatena-export-to-hatena
                      org-hatena-export-to-hatena-and-open) "ox-hatena" nil t))

(eval-when-compile
  (el-clone :repo "0x60df/ox-qmd"))

(with-delayed-execution
 (message "Install ox-qmd...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ox-qmd"))

 (autoload-if-found '(org-qmd-export-as-markdown
                      org-qmd-convert-region-to-md
                      org-qmd-export-to-markdown) "ox-qmd" nil t))

(eval-when-compile
  (el-clone :repo "kaushalmodi/ox-hugo"))

(with-delayed-execution
 (message "Install ox-hugo...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/ox-hugo"))

 (autoload-if-found '(org-hugo-export-as-md
                      org-hugo-export-to-md
                      org-hugo-export-wim-to-md
                      org-hugo-debug-info) "ox-hugo" nil t)

 (with-eval-after-load 'ox-hugo
   (setopt org-hugo-auto-set-lastmod t)))

(eval-when-compile
  (el-clone :repo "org-roam/org-roam"
            :load-paths `(,(locate-user-emacs-file "el-clone/org-roam/extensions"))))

(with-delayed-execution
 (message "Install org-roam...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-roam"))
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-roam/extensions"))

 (autoload-if-found '(org-roam-graph) "org-roam" nil t)
 (keymap-global-set "C-c n g" #'org-roam-graph)

 (with-eval-after-load 'org-roam
   (setopt org-roam-directory "~/org")))

(with-delayed-execution
 (message "Install org-roam-mode...")

 (autoload-if-found '(org-roam-buffer-toggle) "org-roam-mode" nil t)

 (keymap-global-set "C-c n l" #'org-roam-buffer-toggle))

(with-delayed-execution
 (message "Install org-roam-node...")
 (autoload-if-found '(org-roam-node-find org-roam-node-insert) "org-roam-node" nil t)

 (keymap-global-set "C-c n f" #'org-roam-node-find)
 (keymap-global-set "C-c n i" #'org-roam-node-insert)

 (with-eval-after-load 'org-roam-node
   (setopt org-roam-completion-everywhere nil)))

(with-delayed-execution
 (message "Install org-roam-db...")
 (autoload-if-found '(org-roam-db-autosync-enable) "org-roam-db" nil t)

 (org-roam-db-autosync-enable)

 (with-eval-after-load 'org-roam-db
   (setq org-roam-database-connector 'sqlite-builtin)
   (setq org-roam-db-gc-threshold (* 4 gc-cons-threshold))))

(with-delayed-execution
 (message "Install org-roam-capture...")
 (autoload-if-found '(org-roam-capture) "org-roam-capture" nil t)

 (keymap-global-set "C-c n c" #'org-roam-capture)

 (with-eval-after-load 'org-roam-capture
   (setopt org-roam-capture-templates '(("f" "Fleeting(一時メモ)" plain "%?"
                                         :target (file+head "org/fleeting/%<%Y%m%d%H%M%S>-${slug}.org" "#+TITLE: ${title}\n")
                                         :unnarrowed t)
                                        ("l" "Literature(文献)" plain "%?"
                                         :target (file+head "org/literature/%<%Y%m%d%H%M%S>-${slug}.org" "#+TITLE: ${title}\n")
                                         :unnarrowed t)
                                        ("p" "Permanent(記事)" plain "%?"
                                         :target (file+head "org/permanent/%<%Y%m%d%H%M%S>-${slug}.org" "#+TITLE: ${title}\n")
                                         :unnarrowed t)
                                        ("d" "Diary(日記)" plain "%?"
                                         :target (file+head "org/diary/%<%Y%m%d%H%M%S>-${slug}.org" "#+TITLE: ${title}\n")
                                         :unnarrowed t)
                                        ("m" "Private" plain "%?"
                                         :target (file+head "org/private/%<%Y%m%d%H%M%S>.org.gpg" "#+TITLE: ${title}\n")
                                         :unnarrowed t)
                                        ))))

(with-delayed-execution
 (message "Install org-roam-dailies...")
 (autoload-if-found '(org-roam-dailies-map
                      org-roam-dailies-goto-today
                      org-roam-dailies-goto-yesterday
                      org-roam-dailies-goto-tomorrow
                      org-roam-dailies-capture-today
                      org-roam-dailies-goto-next-note
                      org-roam-dailies-goto-previous-note
                      org-roam-dailies-goto-date
                      org-roam-dailies-capture-date
                      org-roam-dailies-find-directory) "org-roam-dailies" nil t)

 (keymap-global-set "C-c n d" #'org-roam-dailies-map)
 (keymap-global-set "C-c n j" #'org-roam-dailies-goto-today)

 (with-eval-after-load 'org-roam-dailies
   ;; config
   (setopt org-roam-dailies-directory "org/daily/")

   ;; keybind
   (define-key org-roam-dailies-map (kbd "d") #'org-roam-dailies-goto-today)
   (define-key org-roam-dailies-map (kbd "y") #'org-roam-dailies-goto-yesterday)
   (define-key org-roam-dailies-map (kbd "t") #'org-roam-dailies-goto-tomorrow)
   (define-key org-roam-dailies-map (kbd "n") #'org-roam-dailies-capture-today)
   (define-key org-roam-dailies-map (kbd "f") #'org-roam-dailies-goto-next-note)
   (define-key org-roam-dailies-map (kbd "b") #'org-roam-dailies-goto-previous-note)
   (define-key org-roam-dailies-map (kbd "c") #'org-roam-dailies-goto-date)
   (define-key org-roam-dailies-map (kbd "v") #'org-roam-dailies-capture-date)
   (define-key org-roam-dailies-map (kbd ".") #'org-roam-dailies-find-directory)))

(with-delayed-execution
 (message "Install org-roam-export...")
 (autoload-if-found '(org-roam-export--org-html--reference) "org-roam-export" nil t)
 (advice-add 'org-html--reference :override #'org-roam-export--org-html--reference))

(with-delayed-execution
 (message "Install org-roam-graph...")
 (autoload-if-found '(org-roam-graph org-roam-graph--open) "org-roam-graph" nil t))

(with-delayed-execution
 (message "Install org-roam-overlay...")
 (autoload-if-found '(org-roam-overlay-mode) "org-roam-overlay" nil t)
 (with-eval-after-load 'org-roam-mode
   (add-hook 'org-roam-mode-hook #'org-roam-overlay-mode)))

(with-delayed-execution
 (message "Install org-roam-protocol...")
 (autoload-if-found '(org-roam-protocol-open-ref org-roam-protocol-open-node) "org-roam-protocol" nil t)
 (with-eval-after-load 'org-roam-protocol
   ;; alist
   (add-to-list 'org-protocol-protocol-alist '("org-roam-ref" :protocol "roam-ref" :function org-roam-protocol-open-ref))
   (add-to-list 'org-protocol-protocol-alist '("org-roam-node" :protocol "roam-node" :function org-roam-protocol-open-node))

   ;; config
   (setopt org-roam-protocol-store-links t)))

(eval-when-compile
  (el-clone :repo "jgru/consult-org-roam"))

(with-delayed-execution
 (message "Install consult-org-roam...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/consult-org-roam"))

 (autoload-if-found '(consult-org-roam-mode) "consult-org-roam" nil t)

 (consult-org-roam-mode)

 ;; keybinds
 (keymap-global-set "C-c n e" #'consult-org-roam-file-find)
 (keymap-global-set "C-c n b" #'consult-org-roam-backlinks)
 (keymap-global-set "C-c n B" #'consult-org-roam-backlinks-recursive)
 (keymap-global-set "C-c n l" #'consult-org-roam-forward-links)
 (keymap-global-set "C-c n r" #'consult-org-roam-search)

 (with-eval-after-load 'consult-org-roam
   (setopt consult-org-roam-grep-func #'consult-ripgrep)
   (setopt consult-org-roam-buffer-narrow-key ?r)
   (setopt consult-org-roam-buffer-after-buffers t)))

(eval-when-compile
  (el-clone :repo "org-roam/org-roam-ui"))

(with-delayed-execution
 (message "Install org-roam-ui...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-roam-ui"))

 (autoload-if-found '(org-roam-ui-mode) "org-roam-ui" nil t)

 (with-eval-after-load 'org-roam-mode
   (add-hook 'org-roam-mode-hook #'org-roam-ui-mode))

 (with-eval-after-load 'org-roam-ui
   (setopt org-roam-ui-sync-theme t)
   (setopt org-roam-ui-follow t)
   (setopt org-roam-ui-update-on-save t)
   (setopt org-roam-ui-open-on-start t)))

(eval-when-compile
  (el-clone :repo "tefkah/org-roam-timestamps"))

(with-delayed-execution
 (message "Install org-roam-timestamps...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-roam-timestamps"))

 (autoload-if-found '(org-roam-timestamps-mode) "org-roam-timestamps" nil t)

 (with-eval-after-load 'org-roam-mode
   (add-hook 'org-roam-mode #'org-roam-timestamps-mode))

 (with-eval-after-load 'org-roam-timestamps
   (setopt org-roam-timestamps-remember-timestamps nil)))

(eval-when-compile
  (el-clone :repo "natask/org-roam-search"))

(with-delayed-execution
 (message "Install org-roam-search...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-roam-search")))

(eval-when-compile
  (el-clone :repo "ahmed-shariff/org-roam-ql"))

(with-delayed-execution
 (message "Install org-roam-ql...")
 (add-to-list 'load-path (locate-user-emacs-file "el-clone/org-roam-ql")))
;; (autoload-if-found '(org-roam-ql-nodes
;;                      org-roam-ql-search
;;                      org-roam-ql-defpred
;;                      org-roam-ql-agenda-buffer-from-roam-buffer
;;                      org-roam-ql-refresh-buffer
;;                      org-dblock-write:org-roam-ql) "org-roam-ql" nil t)
;; (autoload-if-found '(org-roam-ql-ql-init) "org-roam-ql-ql" nil t)

;; (org-roam-ql-ql-init)

(provide 'org-load)
