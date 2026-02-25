{ config, pkgs, lib, ... }:

{
  programs.dconf.enable = true;

  programs.hyprland.enable = !config.remote;

  environment.sessionVariables = if config.remote then
    { }
  else {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
  };

  imports = [ ./greet ./bluetooth ./sound ./power ./networking ./gaming ./ssh ];

}
