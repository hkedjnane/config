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
    [ # Include the results of the hardware scan.
     ./hardware-configuration.nix
     ./default/system.nix
     <nixos-hardware/lenovo/thinkpad/t14/amd/gen4>
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

  services.thinkfan = {
    enable = true;
    levels = [
      [
        0
        0
        55
      ]
      [
        1
        55
        60
      ]
      [
        2
        60
        65
      ]
      [
        3
        65
        70
      ]
      [
        6
        70
        75
      ]
      [
        7
        75
        80
      ]
      [
        "level auto"
        80
        32767
      ]
    ];
  };

  systemd.services.thinkfan.preStart = "
    /run/current-system/sw/bin/modprobe  -r thinkpad_acpi && /run/current-system/sw/bin/modprobe thinkpad_acpi
  ";


  swapDevices = [ 
    {
      device = "/var/lib/swapfile";
      size = 16*1024;
    }
  ];

  services.tlp.enable = false;

  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };


  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;



  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    nameservers = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" ];
    dhcpcd.extraConfig = "nohook resolv.conf";
    networkmanager.dns = "none";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Configure X11 server
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";
  };

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.harsane = {
    isNormalUser = true;
    description = "Harrys Kedjnane";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "docker" ];
    packages = with pkgs; [];
  };

  # Enable automatic login for the user.
  # services.xserver.displayManager.autoLogin.enable = true;
  # services.xserver.displayManager.autoLogin.user = "harsane";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  # systemd.services."getty@tty1".enable = false;
  # systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable automatic login for the user.
  # services.xserver.displayManager.autoLogin.enable = true;
  # services.xserver.displayManager.autoLogin.user = "harsane";

  # Enable docker
  virtualisation.docker.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.opengl.enable = true;



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
  programs.light.enable = true;

  programs.kdeconnect.enable = true;

  programs.steam.enable = true;
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
