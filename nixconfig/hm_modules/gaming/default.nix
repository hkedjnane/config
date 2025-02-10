{lib, pkgs, config, ...}:
lib.mkIf (!config.remote && config.gaming) {
  home.packages = with pkgs; [
    protontricks
  ];
}
