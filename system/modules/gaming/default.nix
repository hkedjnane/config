{ config, pkgs, lib, ... }:
lib.mkIf (!config.remote && config.gaming) {
  programs.steam = {
    enable = true;
    # HDR for every Proton game (native Wayland driver is required for it)
    package = pkgs.steam.override {
      extraEnv = {
        PROTON_ENABLE_WAYLAND = "1";
        PROTON_ENABLE_HDR = "1";
      };
    };
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };
  programs.gamemode.enable = true;

}
