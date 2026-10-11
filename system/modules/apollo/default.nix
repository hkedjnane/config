{ config, pkgs, lib, ... }:
let
  # ports are offsets from the base port, see services.sunshine.openFirewall
  port = config.services.sunshine.settings.port;
  ports = map (offset: port + offset);

  # Streams a headless output sized after the client instead of the physical
  # one. Apollo captures the first output, so the physical ones are disabled
  # for the duration of the stream, which also moves every workspace over.
  headless = pkgs.writeShellApplication {
    name = "apollo-headless";
    runtimeInputs = [ config.programs.hyprland.package pkgs.jq ];
    text = ''
      output=apollo

      case "''${1:-}" in
        start)
          mode="''${SUNSHINE_CLIENT_WIDTH:-1920}x''${SUNSHINE_CLIENT_HEIGHT:-1080}@''${SUNSHINE_CLIENT_FPS:-60}"

          # left over from a stream that did not end cleanly
          hyprctl output remove "$output" > /dev/null
          hyprctl keyword monitor "$output,$mode,auto,1" > /dev/null
          hyprctl output create headless "$output" > /dev/null

          # hyprctl exits 0 even on failure, never go dark without it
          monitors=$(hyprctl monitors all -j)
          if ! jq -e --arg output "$output" 'any(.name == $output)' <<< "$monitors" > /dev/null; then
            echo "could not create headless output $output" >&2
            exit 1
          fi

          for other in $(jq -r --arg output "$output" '.[].name | select(. != $output)' <<< "$monitors"); do
            hyprctl keyword monitor "$other,disable" > /dev/null
          done
          ;;
        stop)
          # re-applies the monitor rules from the config, bringing the
          # physical outputs back before the headless one goes away
          hyprctl reload > /dev/null
          hyprctl output remove "$output" > /dev/null
          ;;
        *)
          echo "usage: apollo-headless start|stop" >&2
          exit 1
          ;;
      esac
    '';
  };
  headlessCmd = {
    do = "${lib.getExe headless} start";
    undo = "${lib.getExe headless} stop";
  };
in
lib.mkIf (!config.remote && config.apollo) {
  # Apollo is a Sunshine fork that keeps the `sunshine` binary name, so the
  # upstream sunshine module (udev rules, uinput, user service) works as-is.
  # The user service is `sunshine.service`, started with the graphical
  # session. Web UI: https://localhost:47990
  services.sunshine = {
    enable = true;
    package = pkgs.callPackage ./package.nix { };
    autoStart = true;
    capSysAdmin = true; # KMS capture
    openFirewall = false;

    # Declaring apps makes them (and the settings) read-only in the web UI.
    # Apollo cannot write generated uuids back to the store, so they are set here.
    # `terminate-on-pause` ends the app when the client disconnects, so the
    # undo commands run then rather than when the app is quit from the client.
    applications = {
      env.PATH = "$(PATH):$(HOME)/.local/bin";
      apps = [
        {
          name = "Desktop";
          uuid = "6f2d4c1e-8a57-4b0e-9c33-1d5e7a90b2f4";
          image-path = "desktop.png";
          prep-cmd = [ headlessCmd ];
          terminate-on-pause = true;
        }
        {
          name = "Steam Big Picture";
          uuid = "b81e03a7-52c9-4d6f-a4e8-0c7f3b96d215";
          image-path = "steam.png";
          prep-cmd = [
            headlessCmd
            {
              do = "";
              undo = "setsid steam steam://close/bigpicture";
            }
          ];
          detached = [ "setsid steam steam://open/bigpicture" ];
          terminate-on-pause = true;
        }
      ];
    };
  };

  # only reachable over tailscale
  networking.firewall.interfaces.${config.services.tailscale.interfaceName} = {
    allowedTCPPorts = ports [ (-5) 0 1 21 ];
    allowedUDPPorts = ports [ 9 10 11 13 21 ];
  };

  # no LAN discovery (the sunshine module turns avahi on by default, which
  # also opens mDNS in the firewall); add the host by its tailscale name/IP
  services.avahi.enable = false;
}
