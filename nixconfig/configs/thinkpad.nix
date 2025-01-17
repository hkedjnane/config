{
  config = {
    darkmode = true;
    remote = false;
    thinkpad = true;
    manageBoot = true;
    managePower = true;
    sync = true;
    hostname = "nixos";
    userList = {
      harsane = {
        isNormalUser = true;
        description = "Harrys Kedjnane";
        extraGroups = [ "networkmanager" "wheel" "audio" "video" "docker" ];
        packages = [];
      };
      stockly = {
        isNormalUser = true;
        description = "Stockly Workstation";
        extraGroups = [ "networkmanager" "wheel" "audio" "video" "docker" ];
        packages = [];
      };
    };
  };

  imports = [
    <nixos-hardware/lenovo/thinkpad/t14/amd/gen4>
  ];
}
