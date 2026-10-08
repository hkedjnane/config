# One bar definition, parameterised over what `waybar-ctl` can change at
# runtime: waybar cannot move or change its exclusivity live, so each
# combination gets its own config file and the bar is restarted between them.
{ position, folded, notifs }:
let
  # Nerd Font glyph from its codepoint, to keep this file readable without
  # the font installed.
  icon = code: builtins.fromJSON ''"\u${code}"'';
in {
  inherit position;
  layer = "top";
  height = 26;
  # Flush with the screen edge, see the tab shape in style.nix.
  margin = "0 10";

  modules-left = [ "hyprland/window" ];
  modules-center = [ "clock" ];
  modules-right = [ "mpris" "custom/notifs" "battery" ];

  "hyprland/window" = {
    format = "{title}";
    max-length = 70;
    icon = false;
  };

  clock = {
    format = "${icon "f017"}  {:%H:%M}";
    format-alt = "${icon "f073"}  {:%A %d %B %Y}";
    tooltip-format = "<tt><small>{calendar}</small></tt>";
    calendar = {
      mode = "month";
      weeks-pos = "left";
      format = {
        months = "<b>{}</b>";
        today = "<b><u>{}</u></b>";
      };
    };
  };

  battery = {
    states = {
      warning = 30;
      critical = 15;
    };
    format = "{icon}  {capacity}%";
    format-charging = "${icon "f0e7"}  {capacity}%";
    format-plugged = "${icon "f1e6"}  {capacity}%";
    format-icons = map icon [ "f244" "f243" "f242" "f241" "f240" ];
    tooltip-format = "{timeTo}\n{power:.1f} W";
  };

  # Current media, hidden when nothing is playing. Left click toggles
  # play/pause, middle and right click go to the previous and next track.
  mpris = {
    format = "{status_icon}  {dynamic}";
    dynamic-order = [ "title" "artist" ];
    dynamic-len = 45;
    status-icons = {
      playing = icon "f001";
      paused = icon "f04c";
      stopped = icon "f04d";
    };
  };

  # Mako state: left click brings the last notification back, middle click
  # dismisses everything, right click toggles do-not-disturb.
  "custom/notifs" = {
    exec = "${notifs}";
    return-type = "json";
    interval = 2;
    on-click = "makoctl restore";
    on-click-middle = "makoctl dismiss --all";
    on-click-right = "makoctl mode -t do-not-disturb";
  };
} // (if folded then {
  # Drawn over the windows and hidden until `waybar-ctl` sees the pointer on
  # the screen edge and signals it.
  exclusive = false;
  start_hidden = true;
  on-sigusr1 = "show";
  on-sigusr2 = "hide";
} else
  { })
