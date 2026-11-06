# JetBrainsMono Nerd Font comes from nixpkgs (reproducible), so the copy in
# ~/dotfiles/.local/share/fonts is NOT deployed by default (it would duplicate).
{ pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts            # includes Malayalam and most scripts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font Mono" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
