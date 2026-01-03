{ config, pkgs, lib, ... }:
lib.mkIf (!config.remote && config.gaming) {
  programs.steam.enable = true;
  programs.gamemode.enable = true;

}
