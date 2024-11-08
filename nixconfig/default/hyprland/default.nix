{pkgs, lib, config, ...}:
let
in
{
    wayland.windowManager.hyprland = {
        enable = true;
        # Basic configuration

        extraConfig = builtins.readFile ./hyprland.conf;
    };


    programs.hyprlock = {
        enable = true;

        extraConfig = builtins.readFile ./hyprlock.conf;
    };

    home.packages = with pkgs; [
      swaybg
      hyprshot
    ];

}
