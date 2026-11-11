{ config, pkgs, lib, ... }:
let
  # Firmware power cap (ThinkPad EC), separate from the cpufreq governor:
  # performance on AC, balanced on battery, low-power when the battery is low.
  lowBatteryPercent = 20;
  setPlatformProfile = pkgs.writeShellScript "set-platform-profile" ''
    f=/sys/firmware/acpi/platform_profile
    [ -w "$f" ] || exit 0
    if [ "$(cat /sys/class/power_supply/AC/online)" = 1 ]; then
      p=performance
    elif [ "$(cat /sys/class/power_supply/BAT0/capacity)" -le ${toString lowBatteryPercent} ]; then
      p=low-power
    else
      p=balanced
    fi
    if [ "$(cat "$f")" != "$p" ]; then
      echo "$p" > "$f"
      echo "platform profile -> $p"
    fi
  '';
in
lib.mkIf config.managePower {
  services.thinkfan = {
    enable = config.thinkpad;
    levels = [
      [ 0 0 55 ]
      [ 1 55 60 ]
      [ 2 60 65 ]
      [ 3 65 70 ]
      [ 6 70 75 ]
      [ 7 75 80 ]
      [ "level auto" 80 32767 ]
    ];
  };

  systemd.services.thinkfan = {
    enable = config.thinkpad;
    preStart =
      "/run/current-system/sw/bin/modprobe  -r thinkpad_acpi && /run/current-system/sw/bin/modprobe thinkpad_acpi";
  };

  systemd.services.platform-profile = lib.mkIf config.thinkpad {
    description = "Set ACPI platform profile from power source and battery level";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = setPlatformProfile;
    };
  };

  # Re-check every minute (battery level, resume) on top of plug/unplug events.
  systemd.timers.platform-profile = lib.mkIf config.thinkpad {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1min";
    };
  };

  services.udev.extraRules = lib.mkIf config.thinkpad ''
    SUBSYSTEM=="power_supply", ACTION=="change", RUN+="${pkgs.systemd}/bin/systemctl start --no-block platform-profile.service"
  '';

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
