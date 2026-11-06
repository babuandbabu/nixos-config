# System-wide packages. Add/remove names here, then rebuild.
# Search names at https://search.nixos.org/packages (channel: unstable).
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # ---- apps ----
    brave
    vscode            # unfree (allowed in modules/system/nix.nix)
    kitty
    localsend         # firewall port opened in networking.nix

    # ---- your utilities ----
    btop yazi zoxide fastfetch git fzf ripgrep fd eza bat jq tree
    curl wget unzip zip p7zip
    wl-clipboard grim slurp brightnessctl playerctl pamixer
    nwg-look qt6Packages.qt6ct
	noctalia 
	mango

    # ---- extra CLI tools ----
    file which psmisc          # file type, which, killall
    pciutils usbutils lshw     # lspci, lsusb, lshw
    smartmontools              # disk health
    ntfs3g                     # NTFS tools for the Windows disk
    nvd nix-output-monitor     # compare generations / nicer build output
    xdg-utils xdg-user-dirs    # xdg-open; run `xdg-user-dirs-update` once
    ncdu                       # disk usage browser
    gcc gnumake                # C toolchain (remove if you don't need it)
  ];
}
