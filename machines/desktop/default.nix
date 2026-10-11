{
  config = {
    darkmode = true;
    remote = false;
    thinkpad = false;
    manageBoot = true;
    managePower = false;
    sync = true;
    gaming = true;
    apollo = true;
    swapfile_gb = 16;
    hostname = "desktop";
    userList = {
      harsane = {
        isNormalUser = true;
        description = "Harrys Kedjnane";
        extraGroups = [ "networkmanager" "wheel" "audio" "video" "docker" ];
        packages = [ ];
        userConfig = import ./users/harsane.nix;
      };
      stockly = {
        isNormalUser = true;
        description = "Stockly Workstation";
        extraGroups = [ "networkmanager" "wheel" "audio" "video" "docker" ];
        packages = [ ];
        userConfig = import ./users/stockly.nix;
      };
    };
    tailscale = true;
  };
}
