{ config, pkgs, lib, ... }@args:
let
  computers =
    builtins.fetchGit { url = "git@github.com:Stockly/Computers.git"; };
in (lib.mkIf (config.stockly) {
  home.packages = with pkgs;
    let jetbrains = (import "${computers}/programs/jetbrains" args);
    in [
      jetbrains.datagrip
      (callPackage "${computers}/programs/insomnia.nix" { })
    ];
})
