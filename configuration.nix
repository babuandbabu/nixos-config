# configuration.nix — just a list of modules. Each module is a small file that
# sets some NixOS options; NixOS merges them all into one system.
# To disable a feature, comment out its line. To add one, create a file and list it.
{ ... }:
{
  imports = [
    # ---- system ----
    ./modules/system/nix.nix
    ./modules/system/boot.nix
    ./modules/system/networking.nix
    ./modules/system/locale.nix
    ./modules/system/audio.nix
    ./modules/system/bluetooth.nix
    ./modules/system/fonts.nix
    ./modules/system/users.nix
    ./modules/system/services.nix
    # ./modules/system/printing.nix   # optional: uncomment to enable printing

    # ---- desktop ----
    ./modules/desktop/mango.nix
    ./modules/desktop/niri.nix        # fallback session
    ./modules/desktop/noctalia.nix
    ./modules/desktop/sddm.nix
    ./modules/desktop/portals.nix
    ./modules/desktop/theming.nix

    # ---- programs ----
    ./modules/programs/packages.nix
    ./modules/programs/zsh.nix
    ./modules/programs/nautilus.nix
  ];
}
