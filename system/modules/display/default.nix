{ config, pkgs, lib, ... }:
let
  # Recent kernels (seen on 6.18, not on 6.12) make amdgpu prefer the EDID the
  # BIOS exposes through ACPI over the panel's own, and Lenovo's copy only
  # advertises 60 Hz. Hand the kernel the EDID read from the panel
  # (ATNA40YK15, 2880x1800@90) instead.
  edid = "edp-atna40yk15.bin";
in lib.mkIf config.thinkpad {
  hardware.display.edid.packages = [
    (pkgs.runCommand "thinkpad-edp-edid" { } ''
      install -Dm444 ${./. + "/${edid}"} "$out/lib/firmware/edid/${edid}"
    '')
  ];
  hardware.display.outputs."eDP-1".edid = edid;
}
