
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [ neovim gcc ];

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink ./config;
}

