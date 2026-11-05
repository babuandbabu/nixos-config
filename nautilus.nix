# Nautilus file manager + helpers (gvfs is enabled in modules/system/services.nix).
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nautilus
    file-roller   # archive extract/compress from Nautilus
  ];
}
