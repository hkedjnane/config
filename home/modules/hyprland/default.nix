{ pkgs, lib, config, ... }:
let
  # Fuzzy window picker across all workspaces, most recently focused first.
  # The current window goes last so that Enter jumps back to the previous one.
  window_picker = pkgs.writeShellScript "window_picker.sh" ''
    jq=${pkgs.jq}/bin/jq
    label='"[\(.workspace.name)] \(.class): \(.title)"'
    clients=$(hyprctl clients -j)

    choice=$($jq -r "map(select(.mapped)) | sort_by(.focusHistoryID) | (.[1:] + .[:1])[] | $label" <<<"$clients" \
      | wofi --show dmenu --insensitive --columns 1 --cache-file /dev/null)
    [ -n "$choice" ] || exit 0

    address=$($jq -r --arg choice "$choice" "map(select($label == \$choice))[0].address // empty" <<<"$clients")
    [ -n "$address" ] && hyprctl dispatch focuswindow "address:$address"
  '';
  # Catppuccin, same flavours as the rest of the config
  palette = if config.darkmode then {
    base = "48, 52, 70";
    baseHex = "303446";
    surface0 = "65, 69, 89";
    surface1 = "81, 87, 109";
    text = "198, 208, 245";
    lavender = "186, 187, 241";
  } else {
    base = "239, 241, 245";
    baseHex = "eff1f5";
    surface0 = "204, 208, 218";
    surface1 = "188, 192, 204";
    text = "76, 79, 105";
    lavender = "114, 135, 253";
  };
in
lib.mkIf (!config.remote) {
  wayland.windowManager.hyprland = {
    enable = true;
    # Workspace overview with live window contents
    plugins = [ pkgs.hyprlandPlugins.hyprtasking ];

    extraConfig = builtins.readFile ./hyprland.conf + ''
      bind = $mainMod, Tab, hyprtasking:toggle, cursor
      # Non consuming, escape must still reach the focused window
      bindn = , escape, hyprtasking:if_active, hyprtasking:toggle cursor
      bind = $mainMod SHIFT, Tab, exec, ${window_picker}

      plugin {
        hyprtasking {
          layout = grid
          bg_color = 0xff${palette.baseHex}
          gap_size = 10
          border_size = 2

          # Press the label shown on a workspace to jump to it
          jump {
            enabled = true
          }

          # 12 cells for the 10 numbered workspaces
          grid {
            rows = 3
            cols = 4
          }
        }
      }

      exec-once = awww-daemon
      # Nearest keeps the pixel art sharp
      exec-once = awww img --filter Nearest --transition-type none ${
        if config.darkmode then
          ./wallpapers/aesthetic-city-dusk.gif
        else
          ./wallpapers/aesthetic-city-latte.gif
      }
    '';
  };

  # Alt + Tab window switcher, registers its own binds in Hyprland
  services.hyprshell = {
    enable = true;
    settings = {
      version = 4;
      windows.switch = {
        modifier = "alt";
        key = "Tab";
        # Defaults to current_monitor, we want every window
        filter_by = [ ];
      };
    };
    # Mirrors the wofi look
    style = ''
      :root {
        --border-color: rgba(${palette.surface1}, 1);
        --border-color-active: rgba(${palette.lavender}, 1);

        --bg-color: rgba(${palette.surface0}, 1);
        --bg-color-hover: rgba(${palette.surface1}, 1);

        --border-radius: 2px;
        --border-size: 2px;
        --border-style: solid;

        --text-color: rgba(${palette.text}, 1);

        --window-padding: 10px;
        --bg-window-color: rgba(${palette.base}, 1);
      }

      .monitor {
        border-color: rgba(${palette.lavender}, 1);
        box-shadow: none;
      }

      label {
        font-family: 'Inconsolata Nerd Font', monospace;
      }
    '';
  };

  programs.hyprlock = {
    enable = true;

    extraConfig = builtins.readFile ./hyprlock.conf;
  };

  home.packages = with pkgs; [ awww hyprshot acpi brightnessctl ];

  home.sessionVariables = { HYPRSHOT_DIR = "$HOME/Pictures/Screenshots"; };

}
