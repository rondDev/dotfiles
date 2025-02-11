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
    ./features/git.nix
    ./features/desktop/hyprland
    ./features/editors/emacs
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
    brightnessctl
    cachix
    cliphist
    cmake
    dbeaver-bin
    direnv
    docker
    fd
    fh
    fzf
    gcc
    gnumake
    keepassxc
    libtool
    mako
    nerdfonts
    nixd
    noto-fonts
    nodePackages.npm
    nodePackages.prettier
    playerctl
    ripgrep
    rustup
    spotify
    steam
    swaylock
    # tableplus
    wakatime
    waybar
    wget
    wofi
    zig
    zls
  ];

  # Enable home-manager and git
  programs.kitty.enable = true;
  programs.home-manager.enable = true;
  programs.git.enable = true;
  programs.neovim.enable = true;
  programs.wofi.enable = true;
  programs.waybar.enable = true;

  services.cliphist.enable = true;
  services.mako.enable = true;


  home.sessionVariables.NIXOS_OZONE_WL = "1";

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
