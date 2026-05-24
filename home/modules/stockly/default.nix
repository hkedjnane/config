{ config, pkgs, lib, ... }@args:
let
  computers =
    builtins.fetchGit { url = "git@github.com:Stockly/Computers.git"; };
in {
  
  home.packages = (lib.mkIf (config.isStockly) (with pkgs;
    let jetbrains = (import "${computers}/programs/jetbrains" args);
    in [
      jetbrains.datagrip
      (callPackage "${computers}/programs/insomnia.nix" { })
      _1password-gui
    ]));
}
