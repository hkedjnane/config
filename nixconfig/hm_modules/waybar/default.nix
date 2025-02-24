{pkgs, lib, config, ...}:
lib.mkIf (!config.remote) {

    programs.waybar = {
        enable = true;
        settings = import ./config.nix;
        style = import ./style.nix;
    };
}
