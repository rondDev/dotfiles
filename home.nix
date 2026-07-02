# { inputs, lib, config, pkgs, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # 1. Define the absolute path to your repo's config folder
  repoConfigPath = "${config.home.homeDirectory}/.config/home-manager/config";

  # 2. Read the directory to get a list of all files/folders inside it
  configDirs = builtins.attrNames (builtins.readDir ./config);

  # 3. Generate a Nix attribute set mapping target paths to out-of-store symlinks
  dotfileSymlinks = builtins.listToAttrs (
    map (name: {
      name = ".config/${name}";
      value = {
        source = config.lib.file.mkOutOfStoreSymlink "${repoConfigPath}/${name}";
      };
    }) configDirs
  );
in
{
  imports = [
    ./modules/eza.nix
    ./modules/git.nix
    # ./modules/cachix.nix
    ./modules/direnv.nix
    # ./modules/emacs
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "spotify" ];

  nixpkgs.overlays = [
    (import (
      builtins.fetchGit {
        url = "https://github.com/nix-community/emacs-overlay.git";
        ref = "master";
        # rev = "550cfdf5570aa09457a9e4f3c878cee535e1d7e2"; # change the revision
        rev = "9df047f0cd70ac7a2c0fa4750394f07677ca3860"; # change the revision
      }
    ))
  ];
  home = {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    username = "rond";
    homeDirectory = "/home/rond";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "24.05"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.

    packages = with pkgs; [
      carapace
      direnv
      fastfetch
      fd
      fh
      glibcLocales
      # spotify
      tofi
      # (nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
      # nerd-fonts.fantasque-sans-mono
      # nerdfonts
      nixd
      nixfmt-rfc-style
      nnn
      # swift
      sqlite

      # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    } // dotfileSymlinks;

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. These will be explicitly sourced when using a
    # shell provided by Home Manager. If you don't want to manage your shell
    # through Home Manager then you have to manually source 'hm-session-vars.sh'
    # located at either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    # or
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    # or
    #  /etc/profiles/per-user/rond/etc/profile.d/hm-session-vars.sh
    #
    sessionVariables = {
      EDITOR = "emacs";
      LANG = "en_US.UTF-8";
      LANGUAGE = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
      NATIVE_FULL_AOT = "true";
      NIXOS_OZONE_WL = "1";
    };
  };

  # Let Home Manager install and manage itself.
  programs = {
    carapace.enable = true;
    carapace.enableNushellIntegration = true;
    home-manager.enable = true;
  };
  # services = { lorri.enable = true; };
}
