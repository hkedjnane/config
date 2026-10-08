{ config, pkgs, lib, ... }:

# LSP support via nvim-lspconfig.
#
# This config never installs a language server. Servers are project-specific:
# each repo provides the ones it wants through its dev shell (loaded by direnv,
# see ./direnv.nix), and we only run a server whose binary is on PATH right now.
# No PATH binary, no server: nothing is downloaded or looked up elsewhere.
#
# The `servers` table below is just "how to talk to X if the project has it".
# Adding a language = adding an entry: its lspconfig name, the command to run
# (always a bare PATH command), and optional settings.
#
# This doubles as the template for adding your own plugin modules: drop a file
# in ./plugins that sets `programs.neovim.plugins`. home-manager merges every
# module's lists together, and ../default.nix imports this directory for you.
{
  programs.neovim.plugins = [{
    plugin = pkgs.vimPlugins.nvim-lspconfig;
    type = "lua";
    config = ''
      -- Buffer-local keymaps, set once a server attaches to a buffer.
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local map = function(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
          end
          map("gd", vim.lsp.buf.definition, "Goto definition")
          map("gD", vim.lsp.buf.declaration, "Goto declaration")
          map("gr", vim.lsp.buf.references, "References")
          map("gi", vim.lsp.buf.implementation, "Goto implementation")
          map("gy", vim.lsp.buf.type_definition, "Goto type definition")
          map("K", vim.lsp.buf.hover, "Hover docs")
          map("<leader>rn", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>e", vim.diagnostic.open_float, "Line diagnostics")
          map("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Prev diagnostic")
          map("]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")

          -- Inlay hints are great for Rust; toggle them if the server offers them.
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
            map("<leader>Th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }), { bufnr = event.buf })
            end, "Toggle inlay hints")
          end
        end,
      })

      -- Nicer diagnostics: show virtual text and sort by severity.
      vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
        float = { border = "rounded", source = true },
      })

      -- Servers we know how to configure. nvim-lspconfig ships the defaults
      -- (filetypes, root markers, ...) under `lsp/<name>.lua`; we layer these
      -- on top. `cmd` is always set explicitly to a bare PATH command, which
      -- also overrides lspconfig's fallbacks (e.g. ts_ls/jsonls looking in
      -- node_modules/.bin).
      local servers = {
        rust_analyzer = {
          cmd = { "rust-analyzer" },
          -- `check.command = "clippy"` gives richer lints on save. allFeatures
          -- + build scripts + proc macros make analysis accurate on real crates.
          settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true, buildScripts = { enable = true } },
              procMacro = { enable = true },
              checkOnSave = true,
              check = { command = "clippy" },
              inlayHints = {
                bindingModeHints = { enable = true },
                closureReturnTypeHints = { enable = "always" },
              },
            },
          },
        },
        lua_ls = {
          cmd = { "lua-language-server" },
          settings = {
            Lua = {
              -- Neovim uses LuaJIT and exposes the `vim` global.
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        nil_ls = { cmd = { "nil" } },
        nixd = { cmd = { "nixd" } },
        clangd = { cmd = { "clangd" } },
        basedpyright = { cmd = { "basedpyright-langserver", "--stdio" } },
        pyright = { cmd = { "pyright-langserver", "--stdio" } },
        ruff = { cmd = { "ruff", "server" } },
        gopls = { cmd = { "gopls" } },
        zls = { cmd = { "zls" } },
        hls = { cmd = { "haskell-language-server-wrapper", "--lsp" } },
        ts_ls = { cmd = { "typescript-language-server", "--stdio" } },
        jsonls = { cmd = { "vscode-json-language-server", "--stdio" } },
        yamlls = { cmd = { "yaml-language-server", "--stdio" } },
        cssls = { cmd = { "vscode-css-language-server", "--stdio" } },
        html = { cmd = { "vscode-html-language-server", "--stdio" } },
        bashls = { cmd = { "bash-language-server", "start" } },
        taplo = { cmd = { "taplo", "lsp", "stdio" } },
        marksman = { cmd = { "marksman", "server" } },
        dockerls = { cmd = { "docker-langserver", "--stdio" } },
        terraformls = { cmd = { "terraform-ls", "serve" } },
      }
      for name, cfg in pairs(servers) do
        vim.lsp.config(name, cfg)
      end

      -- Enable exactly the servers whose binary is on PATH; disable the rest.
      -- (vim.lsp.enable doesn't check this itself: it would try to spawn a
      -- missing binary and error.)
      local function enable_available()
        local on, off = {}, {}
        for name, cfg in pairs(servers) do
          table.insert(vim.fn.executable(cfg.cmd[1]) == 1 and on or off, name)
        end
        if #off > 0 then vim.lsp.enable(off, false) end
        if #on > 0 then vim.lsp.enable(on) end
      end
      enable_available()

      -- When the project env changes (./direnv.nix), stop every server, then
      -- re-enable whatever the new PATH provides. Enabling re-fires FileType
      -- for open buffers, so servers (re)start with the new env, including
      -- ones that already exited (rust-analyzer quits on "cargo not found").
      vim.api.nvim_create_autocmd("User", {
        pattern = "DirenvEnvChanged",
        callback = function()
          for _, client in ipairs(vim.lsp.get_clients()) do client:stop() end
          local tries = 0
          local function restart()
            tries = tries + 1
            -- Wait for old clients to exit, else they'd be reused as-is.
            if #vim.lsp.get_clients() > 0 and tries < 30 then
              return vim.defer_fn(restart, 100)
            end
            enable_available()
          end
          restart()
        end,
      })
    '';
  }];
}
