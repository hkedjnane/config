
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [ waybar ];

  xdg.configFile."waybar".source = ./config;
}

