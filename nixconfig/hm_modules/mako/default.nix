{ pkgs, lib, config, ... }:
lib.mkIf (!config.remote) {
  services.mako = {
    enable = true;
    settings = {
      background-color = "#303446";
      text-color = "#c6d0f5";
      border-color = "#ca9ee6";
      progress-color = "over #414559";
      default-timeout = 5000;
    };
  };
}
