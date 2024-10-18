{config, pkgs, ...}:
{

  home.sessionVariables = {
    TERM = "kitty";
    TERMINAL = "kitty";
  };

  programs.kitty = {
    enable = true;
    font = {
      package = pkgs.hack-font;
      name = "Hack";
    };
    themeFile = "Catppuccin-Frappe";

    settings = {
      confirm_os_window_close = 0;
    };

  };

}
