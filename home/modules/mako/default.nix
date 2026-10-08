{ pkgs, lib, config, ... }:
let
  # Focus the most recently used window of the application that sent the
  # notification with the given id, then dismiss it. For notifications without
  # a default action, where mako has nothing to invoke on click.
  focus-sender = pkgs.writeShellApplication {
    name = "mako-focus-sender";
    runtimeInputs = with pkgs; [
      mako
      jq
      config.wayland.windowManager.hyprland.package
    ];
    text = ''
      id=$1
      notification=$(makoctl list -j | jq -c --argjson id "$id" '.[] | select(.id == $id)')
      [ -n "$notification" ] || exit 0

      # Window classes rarely equal the notification's app name
      # ("DataGrip" vs "jetbrains-datagrip"): compare loosely.
      address=$(hyprctl -j clients | jq -r --argjson n "$notification" '
        def norm: (. // "") | ascii_downcase | gsub("[^a-z0-9]"; "");
        ($n.desktop_entry | norm) as $entry
        | ($n.app_name | norm) as $app
        | map(select(
            (.class | norm) as $class
            | ($entry != "" and ($class | contains($entry)))
              or ($app != "" and ($class | contains($app)))))
        | sort_by(.focusHistoryID)
        | .[0].address // empty')

      if [ -n "$address" ]; then
        hyprctl dispatch focuswindow "address:$address" > /dev/null
      fi
      makoctl dismiss -n "$id"
    '';
  };
in lib.mkIf (!config.remote) {
  services.mako = {
    enable = true;
    settings = {
      background-color = "#303446";
      text-color = "#c6d0f5";
      border-color = "#ca9ee6";
      progress-color = "over #414559";
      default-timeout = 5000;

      # Toggled from the bar (right click on the bell)
      "mode=do-not-disturb" = { invisible = 1; };

      # Left click invokes the notification's default action, which lets the
      # sender raise its own window (needs `focus_on_activate` in
      # hyprland.conf). Senders that offer no action get their window focused
      # for them instead.
      "actionable=false" = {
        on-button-left = ''exec ${lib.getExe focus-sender} "$id"'';
      };
    };
  };
}
