{ config, pkgs, lib, ... }:

# Lualine statusline. Themed to match catppuccin (see ./theme.nix); "auto"
# follows whatever colourscheme is active, so light/dark just works.
{
  programs.neovim.plugins = [
    { plugin = pkgs.vimPlugins.nvim-web-devicons; }
    {
      plugin = pkgs.vimPlugins.lualine-nvim;
      type = "lua";
      config = ''
        require("lualine").setup({
          options = {
            theme = "auto",
            globalstatus = true,
            section_separators = "",
            component_separators = "",
          },
          sections = {
            lualine_c = { { "filename", path = 1 } },
            lualine_x = { "diagnostics", "filetype" },
          },
        })
      '';
    }
  ];
}
