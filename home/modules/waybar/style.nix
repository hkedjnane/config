# Catppuccin palette, `frappe` when `darkmode` is set and `latte` otherwise,
# like the rest of the config.
{ darkmode }:
let
  palettes = {
    frappe = {
      base = "#303446";
      surface0 = "#414559";
      surface1 = "#51576d";
      overlay1 = "#838ba7";
      text = "#c6d0f5";
      lavender = "#babbf1";
      blue = "#8caaee";
      teal = "#81c8be";
      green = "#a6d189";
      yellow = "#e5c890";
      peach = "#ef9f76";
      red = "#e78284";
      mauve = "#ca9ee6";
      pink = "#f4b8e4";
    };
    latte = {
      base = "#eff1f5";
      surface0 = "#ccd0da";
      surface1 = "#bcc0cc";
      overlay1 = "#8c8fa1";
      text = "#4c4f69";
      lavender = "#7287fd";
      blue = "#1e66f5";
      teal = "#179299";
      green = "#40a02b";
      yellow = "#df8e1d";
      peach = "#fe640b";
      red = "#d20f39";
      mauve = "#8839ef";
      pink = "#ea76cb";
    };
  };
  palette = if darkmode then palettes.frappe else palettes.latte;
  colors = builtins.concatStringsSep "\n" (builtins.attrValues
    (builtins.mapAttrs (name: value: "@define-color ${name} ${value};")
      palette));
in ''
  ${colors}

  * {
    font-family: "FantasqueSansM Nerd Font", "Font Awesome 6 Free";
    font-size: 13px;
    min-height: 0;
    border: none;
  }

  window#waybar {
    background: transparent;
    color: @text;
  }

  /* Three tabs hanging from the screen edge rather than a full-width strip. */
  .modules-left,
  .modules-center,
  .modules-right {
    background: alpha(@base, 0.92);
    border: 1px solid @surface1;
    padding: 0 5px;
  }

  /* Square against the screen edge, rounded on the other side. */
  window#waybar.top .modules-left,
  window#waybar.top .modules-center,
  window#waybar.top .modules-right {
    border-top: none;
    border-radius: 0 0 13px 13px;
  }

  window#waybar.bottom .modules-left,
  window#waybar.bottom .modules-center,
  window#waybar.bottom .modules-right {
    border-bottom: none;
    border-radius: 13px 13px 0 0;
  }

  /* No focused window: drop the empty island. */
  window#waybar.empty .modules-left {
    background: transparent;
    border-color: transparent;
  }

  #window,
  #clock,
  #mpris,
  #battery,
  #custom-notifs {
    padding: 0 9px;
  }

  #window {
    color: @lavender;
  }

  #clock {
    color: @blue;
    font-weight: bold;
  }

  #mpris {
    color: @pink;
  }

  #mpris.paused,
  #mpris.stopped {
    color: @overlay1;
  }

  #custom-notifs {
    color: @mauve;
  }

  #custom-notifs.pending {
    color: @peach;
  }

  #custom-notifs.dnd {
    color: @overlay1;
  }

  #battery {
    color: @green;
  }

  #battery.charging,
  #battery.plugged {
    color: @teal;
  }

  #battery.warning:not(.charging) {
    color: @yellow;
  }

  #battery.critical:not(.charging) {
    color: @red;
    animation: blink 1s steps(2) infinite;
  }

  @keyframes blink {
    to {
      color: @surface1;
    }
  }

  tooltip {
    background: @base;
    border: 1px solid @mauve;
    border-radius: 10px;
  }

  tooltip label {
    color: @text;
  }
''
