{ pkgs, ... }:
{
  users.users.daito = {
    isNormalUser = true;
    description = "daito";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"           # sudo
      "networkmanager"  # manage Wi-Fi without root
      "video"           # brightness control
    ];
    # Set the password after install: sudo nixos-enter --root /mnt -c 'passwd daito'
    # (or `passwd` after first login).
  };
}
