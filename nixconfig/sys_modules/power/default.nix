{config, pkgs, lib, ...}:
lib.mkIf config.managePower {
  services.thinkfan = {
    enable = config.thinkpad;
    levels = [
      [
        0
        0
        55
      ]
      [
        1
        55
        60
      ]
      [
        2
        60
        65
      ]
      [
        3
        65
        70
      ]
      [
        6
        70
        75
      ]
      [
        7
        75
        80
      ]
      [
        "level auto"
        80
        32767
      ]
    ];
  };

  systemd.services.thinkfan = {
    enable = config.thinkpad;
    preStart = "/run/current-system/sw/bin/modprobe  -r thinkpad_acpi && /run/current-system/sw/bin/modprobe thinkpad_acpi";
  };


  services.tlp.enable = false;

  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };
}
