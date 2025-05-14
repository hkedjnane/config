{ config, pkgs, ... }:
let
  graphical = with pkgs;
    [
      # Browser
      firefox
      google-chrome

      # Communications
      vesktop
      slack
      thunderbird # Email client

      # Development
      vscode.fhs

      # Media
      spotify
      vlc
      feh
      qbittorrent
      gimp

      # VPN
      protonvpn-gui

      # Desktop utilities
      pavucontrol # Sound control
      filezilla # (S)FTP Client
      nwg-displays # Monitor management

    ] ++ (lib.optionals (config.gaming) [ prismlauncher osu-lazer ]);
in {

  home.packages = with pkgs;
    [

      # VPN
      protonvpn-cli_2

      # CLI utilities
      wget # File downloading
      curl # File downloading
      yazi # File exploration
      xsel # Clipboard manager
      tree # Tree-like file display
      htop # Task Manager
      btop # Better Task Manager
      zip # ZIP creation
      unzip # ZIP decompression
      ripgrep # Supercharged grep
      fzf # Fuzzy finder
      fd # Find but good
      bat # Super cat with syntax highlighting
      tmux # Terminal multiplexer
      comma # Run program from nixpkgs without installing
      neofetch # El famoso
      onefetch # neofetch for git repos
      ncdu # Disk usage explorer
      cht-sh # Cheat sheets
      pamixer # PulseAudio mixer
      playerctl # Media player control
      sshfs # mount a remote ssh directory locally
      p7zip
      file
      man-pages
      man-pages-posix
      wl-clipboard

      # Fonts
      victor-mono
      hack-font
      jetbrains-mono
      fantasque-sans-mono
      font-awesome

      # Humorous
      lolcat

      # Password management
      bitwarden
    ] ++ (lib.optionals (!config.remote) graphical)
    ++ (lib.optionals config.sync [ syncthing ])
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);


  # Media controls daemon
  services.playerctld = {
    enable = !config.remote;
    package = pkgs.playerctl;
  };

  # Add paths to $PATH
  home.sessionPath = [ "$HOME/.local/bin" ];

  home.sessionVariables = {
    SHELL = "fish";
    EDITOR = "nvim";

    # Add a variable to indicate this config is active
    HM_CONFIG_ACTIVE = "1";
  };

  # Enables KDEConnect
  services.kdeconnect.enable = !config.remote;

  # Enable fontconfig
  fonts.fontconfig.enable = true;

  # Enable direnv and nix-direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Audio effects for better sound
  # NOTE: Might wanna run the following command:
  # `bash -c "$(curl -fsSL https://raw.githubusercontent.com/JackHack96/PulseEffects-Presets/master/install.sh)"`
  # to grab some presets.
  services.easyeffects = {
    enable = !config.remote;
    preset = "Laptop";
  };

  imports = [
    # Terminal
    ./kitty

    # Window manager
    ./hyprland

    # Bar

    # App menu
    ./wofi

    # Notification daemon
    ./mako

    # Shells
    ./fish

    # Editors
    ./nvim
    ./helix

    # Tools
    ./git

    ./gaming

    ./stockly

    ./systemd

    ./waybar
  ];

}
