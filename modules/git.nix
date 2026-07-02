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
    userName = "rondDev";
    userEmail = "contact@rond.cc";
    aliases = {
      co = "checkout";
      f = "ls-files | rg -i";
    };
    extraConfig = {
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
