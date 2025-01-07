
{ config, pkgs, lib, ... }:
lib.mkIf (!config.remote) {
  home.packages = with pkgs; [ waybar ];

  xdg.configFile."waybar".source = ./config;
}

