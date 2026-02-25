{
  config = {
    darkmode = true;
    remote = true;
    thinkpad = false;
    manageBoot = true;
    managePower = false;
    sync = false;
    gaming = false;
    tailscale = true;
    swapfile_gb = 4;
    hostname = "homelab";
    userList = {
      main = {
        isNormalUser = true;
        description = "Main";
        extraGroups = [ "networkmanager" "wheel" "audio" "video" "docker" ];
        packages = [ ];
        userConfig = import ./users/main.nix;
	openssh.authorizedKeys.keys = [
	];
      };
    };
    allowedTCPPorts = [ 80 443 ];
  };
}
