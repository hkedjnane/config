{ config, pkgs, lib, ... }:
lib.mkIf (config.remote) {
  services.openssh = {
    enable = true;
    ports = [ 5555 ];
    settings = {
      PermitRootLogin = "no"; 
    };
  };
}
