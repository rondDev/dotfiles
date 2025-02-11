# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./modules/git.nix
    # ./modules/shell
    # ./modules
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # TODO: Set your username
  home = {
    username = "rond";
    homeDirectory = "/home/rond";
  };

  # Add stuff for your user as you see fit:
  # $ nix search wget
  home.packages = with pkgs; [ 
    fh
    fzf
    steam
    wget
    cachix
    zig
    cliphist
  ];


  # Enable home-manager and git
  programs.kitty.enable = true;
  programs.home-manager.enable = true;
  programs.git.enable = true;
  programs.neovim.enable = true;

  wayland.windowManager.hyprland.enable = true;

  # wayland.windowManager.hyprland.settings = {
  #   monitor = "eDP-1,1600x900@60,auto,1";
  #   "$mod" = "SUPER";
  #   "$menu" = "wofi --show drun";
  #   bind = [
  #     "$mod, Return, exec, kitty"
  #     "$mod, D, exec, $menu"
  #   ];
  # };

  home.file."".text = ''

  '';

  home.sessionVariables.NIXOS_OZONE_WL = "1";
  services.cliphist.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
