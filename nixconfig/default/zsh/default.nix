{config, pkgs, ...}:
{

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "ls -l";
      lv = "ls -v";
      rebuild = "sudo nixos-rebuild switch -I nixos-config=/home/harsane/.config/home-manager/configuration.nix";
      hms = "home-manager switch";
    };
    enableAutosuggestions = true;


    zplug = {
      enable = true;

      plugins = [
        { name = "dracula/zsh"; tags = ["as:theme"]; }
      ];
    };

    oh-my-zsh = {
      enable = true;

      plugins = [
        "git"
        "sudo"
        "direnv"
      ];
      theme = "starship";
    };

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.7.0";
          sha256 = "149zh2rm59blr2q458a5irkfh82y3dwdich60s9670kl3cl5h2m1";
        };
      }
    ];
  };
}
