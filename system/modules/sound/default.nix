{ config, pkgs, lib, ... }:
lib.mkIf (!config.remote) {

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # Make a Bluetooth headset the default output as soon as it connects.
    # When it disconnects, WirePlumber falls back to the previous default.
    wireplumber.extraScripts."custom/bluetooth-autoswitch.lua" = ''
      log = Log.open_topic ("s-custom-bt-autoswitch")

      SimpleEventHook {
        name = "custom/bluetooth-autoswitch",
        interests = {
          EventInterest {
            Constraint { "event.type", "=", "node-added" },
            Constraint { "media.class", "=", "Audio/Sink" },
            Constraint { "node.name", "matches", "bluez_output.*" },
          },
        },
        execute = function (event)
          local node = event:get_subject ()
          local name = node.properties ["node.name"]

          local om = event:get_source ():call ("get-object-manager", "metadata")
          local metadata = om:lookup { Constraint { "metadata.name", "=", "default" } }
          if metadata == nil then
            return
          end

          log:info ("bluetooth sink added, making it the default: " .. name)
          metadata:set (0, "default.configured.audio.sink", "Spa:String:JSON",
              Json.Object { ["name"] = name }:to_string ())
        end
      }:register ()
    '';

    wireplumber.extraConfig."99-bluetooth-autoswitch" = {
      "wireplumber.components" = [{
        name = "custom/bluetooth-autoswitch.lua";
        type = "script/lua";
        provides = "custom.bluetooth-autoswitch";
      }];
      "wireplumber.profiles".main."custom.bluetooth-autoswitch" = "required";
    };
  };
}
