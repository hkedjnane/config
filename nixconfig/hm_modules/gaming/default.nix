{lib, pkgs, config, ...}:
lib.mkIf (!config.remote) {
  home.packages = with pkgs; [
    protontricks
  ];
}
