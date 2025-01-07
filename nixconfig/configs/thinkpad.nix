{
  config = {
    darkmode = true;
    remote = false;
    thinkpad = true;
    manageBoot = true;
    managePower = true;
    hostname = "nixos";
    userList = {
      harsane = {
        isNormalUser = true;
        description = "Harrys Kedjnane";
        extraGroups = [ "networkmanager" "wheel" "audio" "video" "docker" ];
        packages = [];
      };
    };
  };

  imports = [
    <nixos-hardware/lenovo/thinkpad/t14/amd/gen4>
  ];
}
