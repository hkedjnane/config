{config, pkgs, ... }:
{
  home.packages = with pkgs; [
    # Browser
    firefox
    google-chrome

    # Communications
    discord 
    slack
    thunderbird #Email client

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
    protonvpn-cli

    # CLI utilities
    wget      # File downloading
    curl      # File downloading
    lf        # File exploration
    xsel      # Clipboard manager
    tree      # Tree-like file display
    htop      # Task Manager
    zip       # ZIP creation
    unzip     # ZIP decompression
    ripgrep   # Supercharged grep
    fzf       # Fuzzy finder
    fd        # Find but good
    bat       # Super cat with syntax highlighting
    tmux      # Terminal multiplexer
    comma     # Run program from nixpkgs without installing
    neofetch  # El famoso
    onefetch  # neofetch for git repos
    ncdu      # Disk usage explorer
    cht-sh    # Cheat sheets
    p7zip
    file

    # Fonts
    victor-mono
    hack-font
    nerdfonts
    jetbrains-mono

    # Desktop utilities
    pavucontrol # Sound control

    # Entertainment
    prismlauncher
    osu-lazer

    # Humorous
    lolcat

    # Others
    bitwarden
  ];

  # Media controls daemon
  services.playerctld = {
    enable = true;
    package = pkgs.playerctl;
  };

  # Add paths to $PATH
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.sessionVariables = {
    SHELL = "fish";
    EDITOR = "nvim";

    # Add a variable to indicate this config is active
    HM_CONFIG_ACTIVE = "1";
  };

  # Enables KDEConnect
  services.kdeconnect.enable = true;

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
    enable = true;
    preset = "Laptop";
  };

  # Sets the default shell to 
  #users.users.shell = pkgs.zsh;

  imports = [
    # Shells
    ./fish

    # Terminal
    ./kitty

    # Editors
    ./nvim
    ./helix

    # Tools
    ./git

    # Window manager
    ./sway
  ];
}
