{ config, pkgs, lib, ... }:

# Telescope: fuzzy finder for files, live grep, buffers, diagnostics, etc.
# The single most useful navigation tool for working in an unfamiliar codebase.
{
  programs.neovim = {
    # `live_grep` shells out to ripgrep; `find_files` uses fd when present.
    extraPackages = with pkgs; [ ripgrep fd ];

    plugins = [
      { plugin = pkgs.vimPlugins.plenary-nvim; }
      { plugin = pkgs.vimPlugins.nvim-web-devicons; }
      # Prebuilt native fzf sorter — much faster matching on large repos.
      { plugin = pkgs.vimPlugins.telescope-fzf-native-nvim; }

      {
        plugin = pkgs.vimPlugins.telescope-nvim;
        type = "lua";
        config = ''
          local telescope = require("telescope")
          telescope.setup({
            defaults = {
              path_display = { "truncate" },
              mappings = {
                i = {
                  ["<C-j>"] = "move_selection_next",
                  ["<C-k>"] = "move_selection_previous",
                },
              },
            },
          })
          pcall(telescope.load_extension, "fzf")

          local builtin = require("telescope.builtin")
          local map = vim.keymap.set
          map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
          map("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
          map("n", "<leader>fw", builtin.grep_string, { desc = "Grep word under cursor" })
          map("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
          map("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
          map("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
          map("n", "<leader>fr", builtin.resume, { desc = "Resume last picker" })
          map("n", "<leader>fo", builtin.oldfiles, { desc = "Recent files" })
          map("n", "<leader><leader>", builtin.find_files, { desc = "Find files" })
          -- LSP-powered pickers (nicer than the raw quickfix lists).
          map("n", "gr", builtin.lsp_references, { desc = "References" })
          map("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Document symbols" })
          map("n", "<leader>fS", builtin.lsp_dynamic_workspace_symbols, { desc = "Workspace symbols" })
        '';
      }
    ];
  };
}
