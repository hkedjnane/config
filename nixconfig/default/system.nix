{config, pkgs, ... }:

{
  # The confguration is handled by home-manager, but we have to enable it system-wide too
  # programs.fish.enable = true;

  # programs.kdeconnect.enable = true;

  # Sets the default shell for my user
  # user.users."harsane".shell = pkgs.fish;

  # Steam is weird so it has to be installed by the system
  # programs.steam.enable = true;

  # services.gnome.gnome-keyring.enable = true;

  programs.dconf.enable = true;

  # users.defaultUserShell = pkgs.fish;


  # This enables fingerprint login
  # services.fprintd.enable = true;
  # services.fprintd.tod.enable = true;
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-vfs0090;

  programs.hyprland.enable = true;
  # Add virtual machine support through libvirt
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
    };
  };

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "harsane" ];

  services.logind.extraConfig = ''
  # don’t shutdown when power button is short-pressed
  HandlePowerKey=suspend
  '';


  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
  };

#



  imports = [
    # Greeter
    ./greet
  ];

}
