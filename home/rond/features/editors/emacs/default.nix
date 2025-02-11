{ lib, pkgs, epkgs, ... }:
let
  emacs-head = pkgs.emacs30-pgtk.overrideAttrs (old: {
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
      "/home/rond/.config/emacs" = {
        source = ./elisp;
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
    package = emacs-head;
  };
}

