{ config, pkgs, lib, ... }:
{
  options = with lib; with types; {
    darkmode = mkOption { type = bool; default = true; };
    remote = mkOption { type = bool; default = false; };
    thinkpad = mkOption { type = bool; default = false; };
    manageBoot = mkOption { type = bool; default = true; };
    managePower = mkOption { type = bool; default = true; };
    hostname = mkOption { type = str; default = "nixos"; };
    userList = mkOption { type = attrs; default = {}; };
    sync = mkOption { type = bool; default = false; };
    gaming = mkOption { type = bool; default = false; };
    swapfile_gb = mkOption { type = int; default = 16; };
    stockly = mkOption { type = bool; default = false; };
    git = mkOption { type = attrs; default = {}; };
    tailsacle = mkOption { type = bool; default = false;};
  };
}
