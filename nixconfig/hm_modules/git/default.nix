{lib, pkgs, config, ...}:
{
  programs.git = {
    inherit (config.git) userEmail userName;
    package = pkgs.gitAndTools.gitFull;
    enable = true;
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
