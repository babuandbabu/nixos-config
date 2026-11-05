# GTK/Qt support. Your settings live in ~/.config/{gtk-3.0,gtk-4.0,qt5ct,qt6ct,
# nwg-look,xsettingsd} (deployed from ~/dotfiles); this module only installs
# what they need.
{ pkgs, ... }:
{
  qt.enable = true; # makes Qt plugins (qt6ct) visible from system packages

  environment.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    NIXOS_OZONE_WL = "1"; # Brave / VS Code use native Wayland
  };

  environment.systemPackages = with pkgs; [
    libsForQt5.qt5ct         # qt6ct itself is in packages.nix
    bibata-cursors           # Bibata-Modern-Ice (env.conf XCURSOR_THEME)
    whitesur-icon-theme      # your install.sh installed WhiteSur icons
    adwaita-icon-theme
    hicolor-icon-theme
    xsettingsd               # you have a config for it (XWayland GTK settings)
  ];
}
