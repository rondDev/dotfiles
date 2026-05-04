;;; lang/astro/config.el -*- lexical-binding: t; -*-
;;; TODO: fix treesitter install errors

;; https://github.com/edmundmiller/.doom.d/blob/main/modules/lang/astro/config.el

(use-package! treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package! astro-ts-mode
  :init
  (add-hook 'astro-ts-mode-hook #'lsp! 'append)
  :config
  (let ((astro-recipe (make-treesit-auto-recipe
                       :lang 'astro
                       :ts-mode 'astro-ts-mode
                       :url "https://github.com/virchau13/tree-sitter-astro"
                       :revision "master"
                       :source-dir "src")))
    (add-to-list 'treesit-auto-recipe-list astro-recipe)))

(set-formatter! 'prettier-astro
  '("npx" "prettier" "--parser=astro"
    ;; '("npx" "prettier"
    (apheleia-formatters-indent "--use-tabs" "--tab-width" 'astro-ts-mode-indent-offset))
  :modes '(astro-ts-mode))

(use-package! lsp-tailwindcss
  :init
  (setq! lsp-tailwindcss-add-on-mode t)
  :config
  (add-to-list 'lsp-tailwindcss-major-modes 'astro-ts-mode)
  (add-to-list 'lsp-tailwindcss-major-modes 'html-mode))

(setq treesit-language-source-alist
      '((astro "https://github.com/virchau13/tree-sitter-astro")
        (css "https://github.com/tree-sitter/tree-sitter-css")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")))

;; MDX Support
(add-to-list 'auto-mode-alist '("\\.\\(mdx\\)$" . markdown-mode))
(when (modulep! +lsp)
  (add-hook 'markdown-mode-local-vars-hook #'lsp! 'append))

;(let ((astro-recipe (make-treesit-auto-recipe
;                     :lang 'astro
;                     :ts-mode 'astro-ts-mode
;                     :url "https://github.com/virchau13/tree-sitter-astro"
;                     :revision "master"
;                     :source-dir "src")))
;  (add-to-list 'treesit-auto-recipe-list astro-recipe))

;; this needs to be executed, but im unsure of where so i just do it interactively
;; (mapc #'treesit-install-language-grammar '(astro css tsx))

