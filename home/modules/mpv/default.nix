{ config, lib, ... }:
let
  # HDR passthrough on Wayland
  mpvConfig = {
    vo = "gpu-next";
    gpu-api = "vulkan";
    target-colorspace-hint = "yes";
    # Follow the media's colorspace, so SDR stays SDR
    target-colorspace-hint-mode = "source";
  };
in
lib.mkIf (!config.remote) {
  programs.mpv = {
    enable = true;
    config = mpvConfig;
  };

  # Cast target for Jellyfin, plays through mpv.
  # It reads its own mpv.conf, not ~/.config/mpv
  services.jellyfin-mpv-shim = {
    enable = true;
    inherit mpvConfig;
  };

  # The service module doesn't put the binary in $PATH
  home.packages = [ config.services.jellyfin-mpv-shim.package ];
}
