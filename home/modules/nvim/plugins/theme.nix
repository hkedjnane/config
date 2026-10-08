{ config, pkgs, lib, ... }:

# Catppuccin colourscheme. Follows the rest of the config: `frappe` when
# darkmode is on (the default), `latte` when it's off.
let flavour = if config.darkmode then "frappe" else "latte";
in {
  programs.neovim.plugins = [{
    plugin = pkgs.vimPlugins.catppuccin-nvim;
    type = "lua";
    config = ''
      require("catppuccin").setup({
        flavour = "${flavour}",
        integrations = {
          native_lsp = { enabled = true },
          treesitter = true,
          telescope = { enabled = true },
          gitsigns = true,
          neotree = true,
          which_key = true,
          blink_cmp = true,
          indent_blankline = { enabled = true },
        },
      })
      vim.cmd.colorscheme("catppuccin-${flavour}")
    '';
  }];
}
