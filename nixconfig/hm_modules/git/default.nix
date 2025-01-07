{lib, pkgs, config, ...}:
{
  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userEmail = "harrys.kedjnane@epita.fr";
    userName = "Harrys Kedjnane";
    extraConfig = {
      push = {
        autoSetupRemote = true;
      };
      init = {
        defaultBranch = "main";
      };
    };
    lfs.enable = true;
  };

  home.packages = with pkgs; [
    pre-commit
  ];
}
