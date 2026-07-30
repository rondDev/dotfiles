{
  description = "Home Manager configuration of rond";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    # nixpkgs.url = "nixpkgs/nixos-24.05";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    org-babel.url = "github:emacs-twist/org-babel";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*.tar.gz";
    television.url = "github:alexpasmantier/television";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      spicetify-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      fonts = {
        packages = builtins.filter pkgs.lib.isDerivation (builtins.attrValues pkgs.nerd-fonts);
      };
    in
    {

      homeConfigurations."rond" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix

        extraSpecialArgs = {
          inherit inputs;
          sys = pkgs.stdenv.hostPlatform.system;
        };
      };
    };
}
