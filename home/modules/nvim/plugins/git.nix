{ config, pkgs, lib, ... }:

# Git integration: signs in the gutter, hunk staging/preview, and blame.
{
  programs.neovim.plugins = [{
    plugin = pkgs.vimPlugins.gitsigns-nvim;
    type = "lua";
    config = ''
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = require("gitsigns")
          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = "Git: " .. desc })
          end

          -- Navigate hunks.
          map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
          map("n", "[h", function() gs.nav_hunk("prev") end, "Prev hunk")

          -- Stage / reset / preview.
          map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
          map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
          map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
          map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
          map("n", "<leader>hd", gs.diffthis, "Diff this")
          map("n", "<leader>Tb", gs.toggle_current_line_blame, "Toggle line blame")
        end,
      })
    '';
  }];
}
