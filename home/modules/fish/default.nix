{ config, pkgs, lib, ... }:
let
  catppuccin-fish = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "fish";
    rev = "HEAD";
    hash = "sha256-3KNWYXfOMzZovdjwjBpjSH8cVlD4CO2QmQcCyQE4Dac=";
  };
  theme = if config.darkmode then "frappe" else "latte";
in {
  xdg.configFile."fish/themes/my_theme.theme".source =
    "${catppuccin-fish}/themes/catppuccin-${theme}.theme";
  xdg.configFile."fish/themes/dark.theme".source =
    "${catppuccin-fish}/themes/catppuccin-frappe.theme";
  xdg.configFile."fish/themes/light.theme".source =
    "${catppuccin-fish}/themes/catppuccin-latte.theme";
  programs.fish = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      lv = "ls -v";
      rebuild =
        "sudo nixos-rebuild switch -I nixos-config=/home/harsane/.config/home-manager/configuration.nix";
      hms = "home-manager switch";
      vim = "nvim";
      temp = ''export LTEMP=$(mktemp -d); cd "$LTEMP";'';
      ltemp = ''cd "$LTEMP"'';
      icat = "kitten icat";
      gs = "git status";
      gc = "git commit";
      gcu = "git commit -u";
      gp = "git push";
      gpf = "git push --force-with-lease";
      gti = "git";
      sl = "ls";
      gitroot = ''cd "$(git rev-parse --show-toplevel)"'';
    };

    functions = {
      gitignore = "curl -sL https://www.gitignore.io/api/$argv";
      fshell = "nix-shell --command fish $argv";
      fdevelop = "nix develop -c fish $argv";
      posix = ''bash -c "$argv"'';
      d = "$argv & disown";
      reload-config = {
        onVariable = "_reload_config";
        body =
          "source ~/.config/fish/config.fish && fish_config theme choose 'my_theme'";
      };
      send = ''scp $argv charybdis:/home/hkedjnane'';
      c = ''
        set rel_path "$argv" 
        test -z "$rel_path"; and set rel_path "."
        set base_path "$(realpath $rel_path)"
        pushd /
        nix-direnv-reload
        code "$base_path"
        popd
      '';
      cr = ''
        set rel_path "$argv" 
        test -z "$rel_path"; and set rel_path "."
        set base_path "$(realpath $rel_path)"
        pushd /
        nix-direnv-reload
        code "$base_path" -r
        popd
      '';
      fish_greeting = "";
    };

    interactiveShellInit = ''
      fish_config theme choose 'my_theme'
    '';

    plugins = [
      {
        name = "nix.fish";
        src = pkgs.fetchFromGitHub {
          owner = "kidonng";
          repo = "nix.fish";
          rev = "HEAD";
    	  sha256 = "3M0dU30SrdjInp6MWEC0q7MTInrZNtY6Z9mhBw43PKs=";
        };
      }
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "HEAD";
          sha256 = "+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
        };
      }
    ];
  };

  home.activation.reloadFish = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.fish}/bin/fish -c 'set -U _reload_config $(random)'
  '';

  programs.starship = let
    flavour = pkgs.lib.strings.toLower
      theme; # One of `latte`, `frappe`, `macchiato`, or `mocha`
  in {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;

    settings = {
      # Other config here
      format = "$all"; # Remove this line to disable the default prompt format
      palette = "catppuccin_${flavour}";
    } // builtins.fromTOML (builtins.readFile (pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "starship";
      rev = "5629d23"; # Replace with the latest commit hash
      sha256 = "sha256-nsRuxQFKbQkyEI4TXgvAjcroVdG+heKX5Pauq/4Ota0=";
    } + /starship.toml));
  };

}
