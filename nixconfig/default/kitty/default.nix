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
    themeFile = if config.darkmode then "Catppuccin-Frappe" else "Catppuccin-Latte";

    settings = {
      confirm_os_window_close = 0;
    };

  };

}
