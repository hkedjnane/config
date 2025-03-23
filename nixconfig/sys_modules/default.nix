{ config, pkgs, lib, ... }:

{
  programs.dconf.enable = true;

  programs.hyprland.enable = !config.remote;

  services.logind.extraConfig = ''
    # don’t shutdown when power button is short-pressed
    HandlePowerKey=suspend
  '';

  environment.sessionVariables = if config.remote then
    { }
  else {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
  };

  imports = [ ./greet ./bluetooth ./sound ./power ./networking ./gaming ./ssh ];

}
