{pkgs, lib, config, ...}:
{
    wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      # Use kitty as default terminal
      terminal = "kitty"; 
      startup = [
      ];
    };
  };

  programs.swaylock = {
      enable = true;
  };
}
