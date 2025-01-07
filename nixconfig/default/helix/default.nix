{ config, pkgs, lib, ... }:
{
  programs.helix = {
    enable = true;
    languages = {
    };

    settings = {
      theme = if config.darkmode then "catppuccin_frappe" else "catppuccin_latte";

      editor = {
        line-number = "relative";
        lsp.display-messages = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
      };
    };
  };

  home.activation.reloadHelix = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run ${pkgs.procps + "/bin/pkill"} -USR1 hx
  '';
}
