{ config, pkgs, lib, ... }:

{
  # Every `.nix` file in ./plugins is imported automatically, so adding a new
  # plugin/module is as simple as dropping a file in there (see ./plugins/lsp.nix
  # for the template). Each of those modules just appends to
  # `programs.neovim.plugins` / `programs.neovim.extraPackages`, which
  # home-manager merges together for us.
  imports = let
    pluginDir = ./plugins;
    nixFiles = builtins.filter (name: lib.hasSuffix ".nix" name)
      (builtins.attrNames (builtins.readDir pluginDir));
  in map (name: pluginDir + "/${name}") nixFiles;

  programs.neovim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Handy for many language servers / plugins.
    withNodeJs = true;

    # Base editor behaviour only. Anything plugin-specific belongs in ./plugins.
    initLua = ''
      -- Leader keys (set before plugins load).
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      local opt = vim.opt

      -- UI
      opt.number = true            -- absolute number on the current line
      opt.relativenumber = true    -- relative numbers elsewhere
      opt.signcolumn = "yes"       -- avoid text shifting when signs appear
      opt.cursorline = true
      opt.termguicolors = true     -- 24-bit colour (required by catppuccin)
      opt.scrolloff = 8
      opt.wrap = false

      -- Indentation
      opt.expandtab = true         -- spaces, not tabs
      opt.shiftwidth = 2
      opt.tabstop = 2
      opt.softtabstop = 2
      opt.smartindent = true

      -- Search
      opt.ignorecase = true
      opt.smartcase = true
      opt.hlsearch = false
      opt.incsearch = true

      -- Editing / files
      opt.clipboard = "unnamedplus" -- use the system clipboard
      opt.undofile = true           -- persistent undo
      opt.swapfile = false
      opt.splitright = true
      opt.splitbelow = true
      opt.mouse = "a"
      opt.updatetime = 250
      opt.timeoutlen = 400

      -- A couple of quality-of-life keymaps.
      local map = vim.keymap.set
      map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
      map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })
      map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
      -- Move between splits with Ctrl+hjkl.
      map("n", "<C-h>", "<C-w>h")
      map("n", "<C-j>", "<C-w>j")
      map("n", "<C-k>", "<C-w>k")
      map("n", "<C-l>", "<C-w>l")
    '';
  };
}
