{ config, pkgs, lib, ... }:

# Quality-of-life editing plugins that are useful in any codebase:
#   - which-key      : popup that shows pending keybindings as you type <leader>
#   - nvim-autopairs : auto-close brackets/quotes
#   - Comment.nvim   : `gcc` / `gc{motion}` to (un)comment, language-aware
#   - indent-blankline : indentation guides
#   - todo-comments  : highlight TODO/FIXME/HACK and jump between them
{
  programs.neovim.plugins = [
    { plugin = pkgs.vimPlugins.plenary-nvim; }

    {
      plugin = pkgs.vimPlugins.which-key-nvim;
      type = "lua";
      config = ''
        local wk = require("which-key")
        wk.setup({})
        -- Name the leader groups so the popup reads nicely.
        wk.add({
          { "<leader>f", group = "find" },
          { "<leader>h", group = "git hunk" },
          { "<leader>c", group = "code" },
          { "<leader>T", group = "toggle" },
          { "<leader>x", group = "diagnostics" },
          { "<leader>r", group = "rename/refactor" },
        })
      '';
    }

    {
      plugin = pkgs.vimPlugins.nvim-autopairs;
      type = "lua";
      config = ''require("nvim-autopairs").setup({})'';
    }

    {
      plugin = pkgs.vimPlugins.comment-nvim;
      type = "lua";
      config = ''require("Comment").setup({})'';
    }

    {
      plugin = pkgs.vimPlugins.indent-blankline-nvim;
      type = "lua";
      config = ''require("ibl").setup({ scope = { enabled = false } })'';
    }

    {
      plugin = pkgs.vimPlugins.todo-comments-nvim;
      type = "lua";
      config = ''
        require("todo-comments").setup({ signs = false })
        local td = require("todo-comments")
        vim.keymap.set("n", "]t", function() td.jump_next() end, { desc = "Next todo comment" })
        vim.keymap.set("n", "[t", function() td.jump_prev() end, { desc = "Prev todo comment" })
      '';
    }
  ];
}
