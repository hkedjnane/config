{ config, pkgs, lib, ... }:

# direnv integration: load each project's `.envrc` (usually a nix-direnv dev
# shell) into Neovim. This is where language servers come from: the project's
# dev shell puts them on PATH (see ./lsp.nix). The env comes from the working
# directory and is reloaded on startup and on :cd (it's process-wide, not
# per-buffer).
#
# direnv.vim loads the environment *asynchronously*, after the first buffers
# have already been opened. So whenever the env actually changes we fire
# `User DirenvEnvChanged`, which ./lsp.nix uses to (re)start servers.
{
  programs.neovim.plugins = [{
    plugin = pkgs.vimPlugins.direnv-vim;
    type = "lua";
    config = ''
      -- Don't echo direnv's "loading / export +AR +CC ..." output on every
      -- load. If a project's env seems missing, check `direnv status` in a
      -- shell (e.g. the .envrc may not be allowed yet).
      vim.g.direnv_silent_load = 1

      -- DirenvLoaded fires after every export, changed or not; DIRENV_DIFF
      -- only changes when the loaded env does.
      local last_diff = vim.env.DIRENV_DIFF
      vim.api.nvim_create_autocmd("User", {
        pattern = "DirenvLoaded",
        callback = function()
          local diff = vim.env.DIRENV_DIFF
          if diff == last_diff then return end
          last_diff = diff
          vim.api.nvim_exec_autocmds("User", { pattern = "DirenvEnvChanged" })
        end,
      })
    '';
  }];
}
