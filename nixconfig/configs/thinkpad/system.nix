{
  config = {
    darkmode = true;
    remote = false;
    thinkpad = true;
    manageBoot = true;
    managePower = true;
    sync = true;
    gaming = true;
    swapfile_gb = 16;
    hostname = "nixos";
    userList = {
      harsane = {
        isNormalUser = true;
        description = "Harrys Kedjnane";
        extraGroups = [ "networkmanager" "wheel" "audio" "video" "docker" ];
        packages = [ ];
      };
      stockly = {
        isNormalUser = true;
        description = "Stockly Workstation";
        extraGroups = [ "networkmanager" "wheel" "audio" "video" "docker" ];
        packages = [ ];
      };
    };
  };
}
