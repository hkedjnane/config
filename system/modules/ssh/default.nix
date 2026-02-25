{ config, pkgs, lib, ... }:
lib.mkIf (config.remote) {
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    openFirewall = false;
    settings = {
      PermitRootLogin = "no"; 
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}
