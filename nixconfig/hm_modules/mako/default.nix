{ pkgs, lib, config, ... }:
let
  catppuccin-config = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "mako";
    rev = "92844f1";
    hash = "sha256-jgiZ+CrM4DX2nZR5BjjD9/Rk5CGGUy3gq9CCvYzp5Vs=";
  };
  flavor = if config.darkmode then
    (catppuccin-config + /themes/catppuccin-frappe/catppuccin-frappe-mauve)
  else
    (catppuccin-config + /themes/catppuccin-latte/catppuccin-latte-mauve);
in lib.mkIf (!config.remote) {
  services.mako = {
    enable = true;
    defaultTimeout = 5000;
  };
}
