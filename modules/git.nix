{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [ ghq ];
  # programs.diff-so-fancy =
  #   {
  #     enable = true;
  #     enableGitIntegration = true;
  #   };
  programs.git = {
    enable = true;
    settings = {
      user.name = "rondDev";
      user.email = "contact@rond.cc";
      alias = {
        co = "checkout";
      };
      github.user = "rondDev";
      gpg = {
        format = "ssh";
      };
      commit.gpgsign = true;
      init = {
        defaultBranch = "dev";
      };
      push = {
        autoSetupRemote = true;
      };
      user.signingkey = "~/.ssh/id_ed25519.pub";
    };
    ignores = [
      "rust_out"
    ];

  };

}
