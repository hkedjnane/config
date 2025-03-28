{
  mainBar = {
    "layer" = "top";
    "position" = "top";
    "modules-left" = [ "wlr/workspaces" ];
    "modules-center" = [ "custom/music" ];
    "modules-right" = [
      "pulseaudio"
      "backlight"
      "battery"
      "clock"
      "tray"
      "custom/lock"
      "custom/power"
    ];
    "wlr/workspaces" = {
      "disable-scroll" = true;
      "sort-by-name" = true;
      "format" = " {icon} ";
      "format-icons" = { "default" = ""; };
    };
    "tray" = {
      "icon-size" = 21;
      "spacing" = 10;
    };
    "custom/music" = {
      "format" = "  {}";
      "escape" = true;
      "interval" = 5;
      "tooltip" = false;
      "exec" = "playerctl metadata --format='{{ title }}'";
      "on-click" = "playerctl play-pause";
      "max-length" = 50;
    };
    "clock" = {
      "timezone" = "Europe/Paris";
      "tooltip-format" = ''
        <big>{:%Y %B}</big>
        <tt><small>{calendar}</small></tt>'';
      "format-alt" = " {:%d/%m/%Y}";
      "format" = " {:%H:%M}";
    };
    "backlight" = {
      "device" = "amdgpu_bl1";
      "format" = "{icon}";
      "format-icons" = [ "" "" "" "" "" "" "" "" "" ];
    };
    "battery" = {
      "states" = {
        "warning" = 30;
        "critical" = 15;
      };
      "format" = "{icon}";
      "format-charging" = "";
      "format-plugged" = "";
      "format-alt" = "{icon}";
      "format-icons" = [ "" "" "" "" "" "" "" "" "" "" "" "" ];
    };
    "pulseaudio" = {
      "format" = "{icon} {volume}%";
      "format-muted" = "";
      "format-icons" = { "default" = [ "" "" " " ]; };
      "on-click" = "pavucontrol";
    };
    "custom/power" = {
      "tooltip" = false;
      "on-click" = "wlogout &";
      "format" = "襤";
    };
  };
}

