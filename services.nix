{ pkgs, ... }:
{
  security.polkit.enable = true;          # privilege prompts (Noctalia has its own agent)
  services.udisks2.enable = true;         # mount USB drives / Windows partitions
  services.gvfs.enable = true;            # Nautilus: trash, MTP phones, network shares
  services.fwupd.enable = true;           # firmware updates
  hardware.enableRedistributableFirmware = true;
  services.power-profiles-daemon.enable = true;  # laptop power profiles
  services.libinput.enable = true;        # touchpad/mouse (SDDM greeter, TTY)
  programs.dconf.enable = true;           # needed by GTK apps and nwg-look
  services.udev.packages = [ pkgs.brightnessctl ]; # backlight permissions
}
