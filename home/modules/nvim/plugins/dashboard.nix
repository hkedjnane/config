{ config, pkgs, lib, ... }:

# Start screen (alpha-nvim) showing Stockly's bird and name, for the Stockly
# user only. The art and its layout live in ./dashboard.lua.
lib.mkIf config.isStockly {
  programs.neovim.plugins = [{
    plugin = pkgs.vimPlugins.alpha-nvim;
    type = "lua";
    config = builtins.readFile ./dashboard.lua;
  }];
}
