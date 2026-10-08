{ config, pkgs, lib, ... }:

# Floating toggle-terminal via toggleterm.nvim, so you never have to leave
# Neovim or open a second terminal.
#
#   <leader>t (normal mode) : toggle a floating terminal over the editor
#   <C-t>     (any mode)     : also toggles it — handy to dismiss it from inside
#                             the shell, where <leader>t would just type a space
#   <C-\><C-n>              : leave terminal-insert mode (Neovim default)
{
  programs.neovim.plugins = [{
    plugin = pkgs.vimPlugins.toggleterm-nvim;
    type = "lua";
    config = ''
      require("toggleterm").setup({
        -- <C-t> works in normal, insert and terminal modes, so it can both
        -- open and dismiss the terminal without a mode dance.
        open_mapping = [[<c-t>]],
        direction = "float",
        float_opts = {
          border = "curved",
          -- Cover most of the editor but leave a little margin so you can see
          -- it's floating "in front of" the code.
          width = function() return math.floor(vim.o.columns * 0.85) end,
          height = function() return math.floor(vim.o.lines * 0.8) end,
        },
        start_in_insert = true,
        persist_mode = false,
        shade_terminals = true,
      })

      -- The requested <leader>t trigger (normal mode only).
      vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm direction=float<cr>",
        { desc = "Toggle terminal" })
    '';
  }];
}
