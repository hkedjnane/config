# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
catppuccin-grub = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "grub";
    rev = "HEAD";
    sha256 = "e8XFWebd/GyX44WQI06Cx6sOduCZc5z7/YhweVQGMGY=";
} + "/src/catppuccin-frappe-grub-theme";
catppuccin-plymouth = pkgs.catppuccin-plymouth.override { variant = "frappe"; };
in
{
  imports =
    [ # Include thm results of the hardware scan.
     ./hardware-configuration.nix
     ./variables.nix
     # Picked configuration, switch to another one if needed
     ./configs/thinkpad.nix
     ./sys_modules
   ];

  # Bootloader.
  boot = {

    supportedFilesystems = [ "ntfs" ];
    kernelModules = [ "kvm-amd" ];

    loader.efi.canTouchEfiVariables = true;
    loader.efi.efiSysMountPoint = "/boot";
    loader.grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;  
        theme = catppuccin-grub;
    };

    plymouth = {
        enable = true;
        themePackages = [ catppuccin-plymouth ];
        theme = "catppuccin-frappe";
    };

    initrd.systemd.enable = true;

    consoleLogLevel = 0;
    kernelParams = [ "quiet" "udev.log_level=0" ];
  };

  swapDevices = [ 
    {
      device = "/var/lib/swapfile";
      size = 16*1024;
    }
  ];

  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;

  networking = {
    hostName = config.hostname;
    networkmanager.enable = true;
    nameservers = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" ];
    dhcpcd.extraConfig = "nohook resolv.conf";
    networkmanager.dns = "none";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure X11 server
  services.xserver = {
    enable = config.remote;
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = config.userList;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable docker
  virtualisation.docker.enable = true;

  hardware.graphics.enable = !config.remote;

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
      auto-optimise-store = true
      binary-caches = https://cache.nixos.org
      trusted-binary-caches = https://cache.nixos.org
    '';
};

  security.polkit.enable = true;
  programs.light.enable = !config.remote;

  programs.kdeconnect.enable = !config.remote;

  programs.steam.enable = !config.remote;
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
