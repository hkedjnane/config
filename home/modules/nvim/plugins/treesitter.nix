{ config, pkgs, lib, ... }:

# Treesitter-powered syntax highlighting, indentation and folding.
#
# `withAllGrammars` builds every parser with Nix and puts them on the
# runtimepath, so highlighting works for essentially any language out of the box
# with no `:TSInstall` and no compiler needed at runtime — the "generalist"
# half of this editor.
#
# Note: nixpkgs ships the rewritten `main` branch of nvim-treesitter. There is
# no `require("nvim-treesitter.configs").setup` anymore; highlighting is a core
# Neovim feature driven per-buffer by `vim.treesitter.start()`.
#
# The tree-sitter CLI is deliberately *not* installed: without it
# `:TSInstall`/`:TSUpdate` can't download and compile grammars behind Nix's
# back. `:checkhealth nvim-treesitter` will warn about it; that's expected.
{
  programs.neovim.plugins = [{
    plugin = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
    type = "lua";
    config = ''
      -- The main branch keeps its bundled queries under <plugin>/runtime/queries,
      -- which is not on the runtimepath by default. Add it so Neovim can find
      -- highlights/indents/folds for the Nix-provided parsers.
      local q = vim.api.nvim_get_runtime_file("runtime/queries", false)[1]
      if q then
        vim.opt.runtimepath:append(vim.fn.fnamemodify(q, ":h"))
      end

      -- Turn on treesitter features for any buffer whose language has a parser.
      -- pcall keeps it quiet for filetypes without one (plain text, logs, ...).
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          end
        end,
      })

      -- Fold using treesitter, but start with everything unfolded.
      vim.opt.foldmethod = "expr"
      vim.opt.foldlevelstart = 99
    '';
  }];
}
