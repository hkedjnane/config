{ lib, pkgs, config, ... }: {
  programs.git = {
    inherit (config.git) userEmail userName;
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    extraConfig = {
      core = {
        commentChar = "%"; # Because Stockly uses `#` in commits
        excludesfile = "~/.gitignore";
        editor = "vim";
        hooksPath = "/home/stockly/Repositories/Main/dev_tools/git_hooks/";
        pager = "less -x1,5";
      };
      push = { autoSetupRemote = true; };
      init = { defaultBranch = "main"; };
      color = { ui = true; };
    };
    lfs.enable = true;

    aliases = {
      a = "add";
      b = "branch";
      c = "commit";
      ca = "commit --amend";
      co = "checkout";
      com = "checkout master";
      cp = "cherry-pick";
      d = "diff";
      ds = "diff --staged";
      l = "log --graph --pretty=oneline --abbrev-commit";
      last = "log -1 HEAD";
      ma = "merge --abort";
      mc = "merge --continue";
      mom = "merge origin/master --no-edit";
      f = "fetch -p";
      pl = "pull";
      ps = "push -u";
      r = "rebase";
      rc = "rebase --continue";
      ri = "rebase -i";
      ra = "rebase --abort";
      riom = "rebase -i origin/master";
      s = "status";
      sw = "switch";
      # Scripts
      arc = "!git add $(git rev-parse --show-toplevel) && git commit";
      arca = "!git add $(git rev-parse --show-toplevel) && git commit --amend";
      arcap =
        "!git add $(git rev-parse --show-toplevel) && git commit --amend && git push -u --force-with-lease";
      arcp =
        "!git add $(git rev-parse --show-toplevel) && git commit && git push -u";
      pmp = "!git pl && git mom && git ps";
      wip = "!git add $(Wgit rev-parse --show-toplevel) && git commit -m 'wip'";
      wipp =
        "!git add $(git rev-parse --show-toplevel) && git commit -m 'wip' && git push -u";
    };
  };

  home.packages = with pkgs; [ pre-commit ];
}
