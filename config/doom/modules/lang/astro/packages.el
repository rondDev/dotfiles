;; -*- no-byte-compile: t; -*-
;;; lang/astro/packages.el

;; https://github.com/edmundmiller/.doom.d/blob/d69eac7db7d201c091f9d6b96ff38d0f93b658c0/modules/lang/astro/packages.el
(package! treesit-auto)
(package! astro-ts-mode)

(when (modulep! +lsp)
  (package! lsp-tailwindcss
    :recipe (:host github :repo "merrickluo/lsp-tailwindcss")))
