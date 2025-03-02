{ pkgs, lib, config, ... }:
lib.mkIf (!config.remote) {
  wayland.windowManager.hyprland = {
    enable = true;
    # Basic configuration

    extraConfig = builtins.readFile ./hyprland.conf;
  };

  programs.hyprlock = {
    enable = true;

    extraConfig = builtins.readFile ./hyprlock.conf;
  };

  home.packages = with pkgs; [ swaybg hyprshot acpi ];

  home.sessionVariables = { HYPRSHOT_DIR = "$HOME/Pictures/Screenshots"; };

}
