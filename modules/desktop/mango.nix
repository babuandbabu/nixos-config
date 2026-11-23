{ inputs, pkgs, ... }:

{
  imports = [
    inputs.mangowm.nixosModules.mango
  ];

  programs.mango.enable = true;
  programs.xwayland.enable = true;

  services.displayManager.defaultSession = "mango";

  environment.systemPackages = with pkgs; [
    cliphist
    libnotify
    wlr-randr
    glib
    gsettings-desktop-schemas
  ];
}
