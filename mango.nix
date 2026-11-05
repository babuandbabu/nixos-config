# MangoWM. The module comes from the `mangowm` flake input (see flake.nix).
# It installs mango, sets up the Wayland environment and adds a "mango" session
# to the display manager (programs.mango.addLoginEntry defaults to true).
# Your config stays in ~/.config/mango (deployed from ~/dotfiles).
{ pkgs, ... }:
{
  programs.mango.enable = true;
  programs.xwayland.enable = true;                  # run X11 apps
  services.displayManager.defaultSession = "mango"; # preselect in SDDM

  # Tools your mango scripts call (found by reading autostart.sh, bind.conf,
  # reload.sh, screenshot.sh):
  environment.systemPackages = with pkgs; [
    cliphist        # autostart.sh: clipboard history
    libnotify       # notify-send in reload.sh / screenshot.sh
    wlr-randr       # monitor.conf comment suggests it for refresh-rate checks
    glib            # `gsettings` in autostart.sh
    gsettings-desktop-schemas
  ];
  # Already provided elsewhere: wl-clipboard, grim, slurp, brightnessctl,
  # playerctl (packages.nix), wpctl (audio.nix), dbus-update-activation-environment (NixOS).
}
