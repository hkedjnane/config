{config, pkgs, lib, ...}:
lib.mkIf (!config.remote) {
  programs.steam.enable = true;
  programs.gamemode.enable = true;


}
