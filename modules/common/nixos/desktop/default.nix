{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = lib.mkDefault true;
  services.xserver.displayManager.gdm.wayland = lib.mkDefault true;
  services.xserver.desktopManager.gnome.enable = lib.mkDefault true;
}
