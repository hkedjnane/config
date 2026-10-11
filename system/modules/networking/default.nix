{ config, pkgs, lib, ... }: {
  networking = {
    hostName = config.hostname;
    networkmanager = {
      enable = true;
      wifi = {
        # Machines on mains power only, a laptop wants the battery savings
        powersave = lib.mkIf (!config.managePower) false;
      };
    };
    nameservers = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" ];
    dhcpcd.extraConfig = "nohook resolv.conf";
    networkmanager.dns = "none";
    firewall = {
       allowedTCPPorts = config.allowedTCPPorts;
       enable = true;
    };
  };

  services.tailscale = {
      enable =  config.tailscale;
  };
}
