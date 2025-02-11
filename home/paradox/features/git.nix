{lib, pkgs, ...}: {
  home.packages = with pkgs; [ ghq ];
  programs.git = {
    enable = true;
    userName = "rondDev";
    userEmail = "contact@rond.cc";
    diff-so-fancy.enable = true;
    signing.key = "~/.ssh/id_ed25519";
    aliases = {
      co = "checkout";
      f = "ls-files | rg -i";
    };
    extraConfig = {
      github.user = "rondDev";
      gpg = { format = "ssh"; };
      commit.gpgsign = true;
      init = { defaultBranch = "main"; };
      push = { autoSetupRemote = true; };
      user.signingkey = "~/.ssh/id_ed25519.pub";
    };
  };
}
