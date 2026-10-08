{ config, pkgs, lib, ... }:

# Formatting via conform.nvim. Formats on save and on <leader>cf.
#
# Like language servers (see ./lsp.nix), formatters are never installed here:
# the project's dev shell (loaded by direnv) puts them on PATH. The table below
# only maps filetypes to formatters to use *if* the project provides them;
# conform skips any whose binary isn't on PATH and falls back to the LSP
# server's formatting.
{
  programs.neovim.plugins = [{
    plugin = pkgs.vimPlugins.conform-nvim;
    type = "lua";
    config = ''
      local prettier = { "prettier" }
      require("conform").setup({
        formatters_by_ft = {
          rust = { "rustfmt" },
          lua = { "stylua" },
          -- Projects pick their own Nix style; use the first one available.
          nix = { "nixfmt", "alejandra", "nixpkgs_fmt", stop_after_first = true },
          c = { "clang_format" },
          cpp = { "clang_format" },
          python = { "ruff_format" },
          go = { "gofmt" },
          sh = { "shfmt" },
          toml = { "taplo" },
          javascript = prettier,
          typescript = prettier,
          javascriptreact = prettier,
          typescriptreact = prettier,
          json = prettier,
          jsonc = prettier,
          css = prettier,
          html = prettier,
          yaml = prettier,
          markdown = prettier,
        },
        formatters = {
          -- conform's default looks in node_modules/.bin first; only use PATH.
          prettier = { command = "prettier" },
        },
        -- Format on save; if none of the filetype's formatters is on PATH, ask
        -- the LSP server instead. `quiet`: a missing formatter is normal here
        -- (the project just doesn't provide one), so don't warn on every save.
        format_on_save = {
          timeout_ms = 2000,
          lsp_format = "fallback",
          quiet = true,
        },
      })

      -- Manual format does warn, so you can tell when nothing is available.
      vim.keymap.set({ "n", "v" }, "<leader>cf", function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end, { desc = "Format buffer" })
    '';
  }];
}
