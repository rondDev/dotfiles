{ lib, pkgs, epkgs, ... }:
let
  emacs-head = pkgs.emacs-pgtk.overrideAttrs (old: {
    configureFlags = old.configureFlags ++ [
      "--with-native-compilation=aot"
      "--with-tree-sitter"
      "--with-pgtk"
      "--with-sqlite3=yes"
      "--with-harfbuzz"
      "--with-libsystemd"
      "--with-modules"
      "--disable-build-details"
    ];
  });
in {
  home = {
    file = {
      ".config/emacs.nix/early-init.el".text =
        (builtins.readFile ../../modules/emacs/elisp/early-init.el);
      ".config/emacs.nix/init.el".text =
        (builtins.readFile ../../modules/emacs/elisp/init.el);
      ".config/emacs.nix/extras" = {
        source = ../../modules/emacs/elisp/extras;
        recursive = true;
      };
    };
    packages = with pkgs; [
      emacs-lsp-booster
      pinentry-emacs
      sqlite
    ];
  };
  programs.emacs = {
    enable = true;
    package = (pkgs.emacsWithPackagesFromUsePackage {
      config = "~/.config/emacs.nix/";
      package = emacs-head.override {
        # withGTK3 = true;
        # withX = false;
        # withTreeSitter = true;
        # withNativeCompilation = true;
      };
      extraEmacsPackages = epkgs:
        with epkgs; [
          # flycheck
          # forge
          # affe
          # anzu
          # apheleia
          # avy
          # benchmark-init
          # blamer
          # cape
          # consult
          # consult-projectile
          # consult-lsp
          # corfu
          # dash
          # dashboard
          # denote
          # doom-themes
          # dumb-jump
          # editorconfig
          # eldoc-box
          # elnode
          # emacsql-sqlite-builtin
          # embark
          # embark-consult
          # emmet-mode
          # esup
          # evil
          # evil-collection
          # evil-escape
          # evil-goggles
          # evil-nerd-commenter
          # evil-surround
          # exec-path-from-shell
          # f
          # fish-mode
          # gcmh
          # general
          # ghub
          # gist
          # git-gutter
          # git-gutter-fringe
          # helpful
          # hl-todo
          # kotlin-mode
          # link-hint
          # lsp-mode
          # lsp-ui
          # lua-mode
          # magit
          # magit-file-icons
          # magit-section
          # marginalia
          # multi-vterm
          # nerd-icons
          # nerd-icons-completion
          # nerd-icons-corfu
          # nerd-icons-dired
          # nerd-icons-ibuffer
          # nix-mode
          # orderless
          # org-bullets
          # org-super-agenda
          # # org-roam
          # page-break-lines
          # parinfer-rust-mode
          # persistent-scratch
          # persp-mode
          # popper
          # projectile
          # pulsar
          # rainbow-delimiters
          # rainbow-mode
          # rustic
          # s
          # sideline
          # sideline-flymake
          # smartparens
          # spacious-padding
          # sqlite3
          # swift-mode
          # tempel
          # tempel-collection
          # transient
          # treesit-auto
          # undo-fu
          # undo-fu-session
          # v-mode
          # vertico
          # vterm
          # wakatime-mode
          # web-mode
          # which-key
          # xclip
          # yasnippet
          # yasnippet-snippets
        ];
    });
  };
}

