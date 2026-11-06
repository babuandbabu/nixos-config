# XDG portals: screen sharing, screenshots, file pickers.
# Replaces the Fedora-only /usr/libexec portal lines in autostart.sh.
{ pkgs,lib, ... }:
{
  xdg.portal = {
    enable = true;
    wlr.enable = true;                       # screen capture on wlroots compositors
    extraPortals = [ 
	pkgs.xdg-desktop-portal-gtk
	pkgs.xdg-desktop-portal-wlr
    ];
    config = {
      common.default = [ "gtk" ];
      # Name matches XDG_CURRENT_DESKTOP=mango from your env.conf
      mango.default =lib.mkForce [ "wlr" "gtk"];
    };
  };
}
