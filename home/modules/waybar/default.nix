{ pkgs, lib, config, ... }:
let
  waybar = config.programs.waybar.package;

  # Waybar `custom/notifs` module: mako's pending count, do-not-disturb state
  # and the latest history entries as tooltip.
  notifs = pkgs.writeShellApplication {
    name = "waybar-notifs";
    runtimeInputs = with pkgs; [ mako jq gnugrep ];
    text = ''
      pending=$(makoctl list -j 2>/dev/null) || pending='[]'
      history=$(makoctl history -j 2>/dev/null) || history='[]'
      dnd=false
      if makoctl mode 2>/dev/null | grep -qx do-not-disturb; then
        dnd=true
      fi

      jq -cn --argjson pending "$pending" --argjson history "$history" \
        --argjson dnd "$dnd" '
        ($pending | length) as $count
        | {
            text: ((if $dnd then "" else "" end)
              + (if $count > 0 then "  \($count)" else "" end)),
            class: (if $dnd then "dnd" elif $count > 0 then "pending" else "idle" end),
            tooltip: ([
                (if $dnd then "Do not disturb" else "\($count) pending" end)
              ] + ($history[:5] | map("<b>\(.app_name | @html)</b>  \(.summary | @html)"))
              | join("\n"))
          }'
    '';
  };

  mkBar = { position, folded }:
    import ./config.nix {
      inherit position folded;
      notifs = lib.getExe notifs;
    };

  json = pkgs.formats.json { };

  # <position>[-folded].json for every state `waybar-ctl` can be in.
  barConfigs = pkgs.linkFarm "waybar-configs" (lib.concatMap (position:
    map (folded: {
      name = "${position}${lib.optionalString folded "-folded"}.json";
      path = json.generate "waybar-${position}.json" [
        (mkBar { inherit position folded; })
      ];
    }) [ false true ]) [ "top" "bottom" ]);

  # Runs the bar and owns its state (shown or not, top or bottom, folded or
  # not), which is kept across sessions. See the binds in hyprland.conf.
  waybar-ctl = pkgs.writeShellApplication {
    name = "waybar-ctl";
    runtimeInputs = with pkgs; [
      waybar
      config.wayland.windowManager.hyprland.package
      jq
      coreutils
      util-linux
    ];
    text = ''
      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/waybar-ctl"
      run_dir="''${XDG_RUNTIME_DIR:-/tmp}/waybar-ctl"
      pidfile="$run_dir/pid"
      mkdir -p "$state_dir" "$run_dir"

      get() {
        if [ -f "$state_dir/$1" ]; then cat "$state_dir/$1"; else echo "$2"; fi
      }
      put() { echo "$2" > "$state_dir/$1"; }

      running() {
        [ -f "$pidfile" ] && kill -0 "$(<"$pidfile")" 2>/dev/null
      }

      stop() {
        if running; then
          local pid
          pid=$(<"$pidfile")
          kill "$pid" 2>/dev/null || true
          while kill -0 "$pid" 2>/dev/null; do sleep 0.02; done
        fi
        rm -f "$pidfile"
      }

      # Restart the bar so that it matches the saved state.
      apply() {
        stop
        if [ "$(get visible 1)" = 1 ]; then
          setsid -f "$0" run 9>&- > "$run_dir/log" 2>&1
        fi
      }

      # Logical geometry of every monitor, as "x y width height".
      load_monitors() {
        mapfile -t monitors < <(hyprctl -j monitors | jq -r '
          .[]
          | (if .transform % 2 == 1 then [.height, .width] else [.width, .height] end) as [$w, $h]
          | "\(.x) \(.y) \($w / .scale | floor) \($h / .scale | floor)"')
      }

      # Distance in pixels between the pointer and the bar's screen edge, on
      # the monitor the pointer is on.
      edge_distance() {
        local position=$1 cx cy mx my mw mh monitor
        IFS=', ' read -r cx cy < <(hyprctl cursorpos)
        for monitor in "''${monitors[@]}"; do
          read -r mx my mw mh <<< "$monitor"
          if (( cx >= mx && cx < mx + mw && cy >= my && cy < my + mh )); then
            if [ "$position" = top ]; then
              echo $(( cy - my ))
            else
              echo $(( my + mh - 1 - cy ))
            fi
            return
          fi
        done
        echo 9999
      }

      # Show the bar once the pointer rests on its screen edge, hide it again
      # once the pointer has left it.
      autohide() {
        local bar=$1 position=$2
        local shown=0 dwell=0 away=0 tick=0 distance
        local reveal_at=1 hide_beyond=42
        while kill -0 "$bar" 2>/dev/null; do
          if (( tick % 40 == 0 )); then load_monitors; fi
          tick=$(( tick + 1 ))
          distance=$(edge_distance "$position") || break

          if (( shown == 0 )); then
            # Two polls in a row, so that merely crossing from one monitor
            # to the next does not reveal it.
            if (( distance <= reveal_at )); then dwell=$(( dwell + 1 )); else dwell=0; fi
            if (( dwell >= 2 )); then
              kill -USR1 "$bar"
              shown=1 dwell=0 away=0
            fi
          else
            if (( distance > hide_beyond )); then away=$(( away + 1 )); else away=0; fi
            if (( away >= 4 )); then
              kill -USR2 "$bar"
              shown=0 away=0
            fi
          fi
          sleep 0.12
        done
      }

      case "''${1:-}" in
        run)
          position=$(get position bottom)
          folded=$(get folded 0)
          config="${barConfigs}/$position"
          if [ "$folded" = 1 ]; then config+="-folded"; fi

          echo $$ > "$pidfile"
          waybar -c "$config.json" &
          bar=$!
          trap 'kill "$bar" 2>/dev/null || true; wait "$bar" 2>/dev/null || true' EXIT
          trap 'exit 0' TERM INT

          if [ "$folded" = 1 ]; then
            autohide "$bar" "$position"
          else
            wait "$bar" || true
          fi
          ;;
        start | toggle | move | fold)
          exec 9> "$run_dir/lock"
          flock 9
          case "$1" in
            start) ;;
            toggle)
              if running; then put visible 0; else put visible 1; fi
              ;;
            move)
              if [ "$(get position bottom)" = top ]; then
                put position bottom
              else
                put position top
              fi
              put visible 1
              ;;
            fold)
              put folded $(( 1 - $(get folded 0) ))
              put visible 1
              ;;
          esac
          apply
          ;;
        *)
          echo "usage: waybar-ctl start|toggle|move|fold" >&2
          exit 1
          ;;
      esac
    '';
  };
in lib.mkIf (!config.remote) {

  programs.waybar = {
    enable = true;
    # Plain `waybar` gets the default state, `waybar-ctl` picks the others.
    settings = [ (mkBar { position = "bottom"; folded = false; }) ];
    style = import ./style.nix { inherit (config) darkmode; };
  };

  home.packages = [ waybar-ctl ];
}
