{ config, pkgs, lib, ... }:
lib.mkIf (!config.remote) {
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "Hyprland";
        user = "harsane";
      };
    };
  };

  /*programs.regreet = {
    enable = true;
  };*/
}
