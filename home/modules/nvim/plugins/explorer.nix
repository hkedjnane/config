{ config, pkgs, lib, ... }:

# Neo-tree file explorer. Toggle with <C-n>; <leader>E reveals the current file.
{
  programs.neovim.plugins = [
    { plugin = pkgs.vimPlugins.plenary-nvim; }
    { plugin = pkgs.vimPlugins.nui-nvim; }
    { plugin = pkgs.vimPlugins.nvim-web-devicons; }

    {
      plugin = pkgs.vimPlugins.neo-tree-nvim;
      type = "lua";
      config = ''
        require("neo-tree").setup({
          close_if_last_window = true,
          filesystem = {
            follow_current_file = { enabled = true },
            use_libuv_file_watcher = true,
            filtered_items = { hide_dotfiles = false, hide_gitignored = true },
          },
        })
        vim.keymap.set("n", "<C-n>", "<cmd>Neotree toggle<cr>", { desc = "Toggle file explorer" })
        vim.keymap.set("n", "<leader>E", "<cmd>Neotree reveal<cr>", { desc = "Reveal file in explorer" })
      '';
    }
  ];
}
