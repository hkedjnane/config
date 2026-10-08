{ config, pkgs, lib, ... }:

# Autocompletion via blink.cmp (fast, Lua+Rust, minimal config). This is what
# turns LSP into an actually usable editing experience: as-you-type completion
# from the language server, snippets, paths and buffer words.
{
  programs.neovim.plugins = [
    # A big collection of ready-made snippets; blink picks them up automatically.
    { plugin = pkgs.vimPlugins.friendly-snippets; }

    {
      plugin = pkgs.vimPlugins.blink-cmp;
      type = "lua";
      config = ''
        require("blink.cmp").setup({
          -- "enter" preset: <CR> accepts the selected item while the menu is
          -- open (a plain newline otherwise), <C-space> open, <C-e> cancel,
          -- <C-n>/<C-p> (and <Up>/<Down>) to cycle, <Tab>/<S-Tab> for snippets.
          keymap = { preset = "enter" },
          appearance = { nerd_font_variant = "mono" },
          completion = {
            documentation = { auto_show = true, auto_show_delay_ms = 200 },
            menu = { border = "rounded" },
          },
          signature = { enabled = true },
          -- The Rust fuzzy matcher is built by Nix (nixpkgs' blink-cmp ships
          -- it); never fetch a prebuilt binary from GitHub.
          fuzzy = { prebuilt_binaries = { download = false } },
          sources = {
            default = { "lsp", "path", "snippets", "buffer" },
          },
        })

        -- Advertise blink's richer client capabilities (snippet resolution,
        -- extra completion item fields, ...) to *every* LSP server. Applying it
        -- to "*" means new servers added in lsp.nix get it for free.
        vim.lsp.config("*", {
          capabilities = require("blink.cmp").get_lsp_capabilities(),
        })
      '';
    }
  ];
}
