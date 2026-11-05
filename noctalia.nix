# Noctalia v5 is installed as a plain package (its flake has no NixOS module).
# It is STARTED by your ~/.config/mango/autostart.sh (`noctalia &`), so no
# systemd service or second launcher is added here -> no duplicate shells.
# Noctalia provides bar, launcher, notifications (do NOT install mako/dunst),
# control center, tray, wallpaper, OSD, lock screen and its own polkit agent.
{ pkgs, inputs, ... }:
{
  environment.systemPackages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.sound-theme-freedesktop # your config uses sound_theme = "freedesktop"
  ];

  services.upower.enable = true; # battery info (documented Noctalia requirement)
}
