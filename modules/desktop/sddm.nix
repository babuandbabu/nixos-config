# SDDM with the Astronaut theme. Uses the community `sddm-astronaut` package
# from nixpkgs, customised with .override (the old wiki-style examples are stale).
{ pkgs, ... }:
let
  sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "japanese_aesthetic";
    themeConfig = {
      HeaderTextColor = "#d5c4a1";
      # Custom background: see README ("Custom SDDM background").
    };
  };
in
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    package = pkgs.kdePackages.sddm; # Qt6 SDDM (required by the theme)
    theme = "sddm-astronaut-theme";
    # Greeter runs on X11 (most robust). Session itself is Wayland (mango).
    extraPackages = [
      sddm-astronaut
      pkgs.kdePackages.qtmultimedia # animated backgrounds
      pkgs.kdePackages.qtsvg
      pkgs.kdePackages.qtvirtualkeyboard
    ];
  };

  # The theme must be in the system profile too (so the path below exists).
  environment.systemPackages = [ sddm-astronaut ];
  # Expected path: /run/current-system/sw/share/sddm/themes/sddm-astronaut-theme
}
