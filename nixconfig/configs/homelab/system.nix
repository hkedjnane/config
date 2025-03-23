{
  config = {
    darkmode = true;
    remote = true;
    thinkpad = false;
    manageBoot = true;
    managePower = false;
    sync = false;
    gaming = false;
    swapfile_gb = 16;
    hostname = "homelab";
    userList = {
      harsane = {
        isNormalUser = true;
        description = "Harrys Kedjnane";
        extraGroups = [ "networkmanager" "wheel" "audio" "video" "docker" ];
        packages = [ ];
      };
    };
  };
}
