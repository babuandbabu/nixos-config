# Dual boot with Windows using GRUB + os-prober.
# Why GRUB and not systemd-boot: Windows' EFI partition is often only 100-260 MB;
# systemd-boot copies kernels onto it and would fill it up. With GRUB the kernels
# live on the NixOS root filesystem and the Windows ESP just holds the bootloader.
#
# REQUIREMENT: during install, mount the (Windows) EFI partition at /boot/efi.
# hardware-configuration.nix will then list it; keep efiSysMountPoint in sync.
{ pkgs, ... }:
{
  boot.loader = {
    timeout = 5;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi"; # TODO: must match where your ESP is mounted
    };
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";          # UEFI: no disk device needed
      useOSProber = true;        # adds "Windows Boot Manager" entry on each rebuild
      configurationLimit = 20;   # keep the last 20 generations in the menu
    };
  };

  # Windows keeps the hardware clock in LOCAL time, Linux in UTC. This makes
  # Linux match Windows so the time does not jump when you switch.
  time.hardwareClockInLocalTime = true;

  # Read/write the Windows NTFS partitions.
  boot.supportedFilesystems = [ "ntfs" ];

  environment.systemPackages = [ pkgs.efibootmgr pkgs.os-prober ];

  # Using systemd-boot instead (only if your ESP is >= 512 MB): remove the grub
  # block above and set:
  #   boot.loader.systemd-boot.enable = true;
  #   boot.loader.efi.efiSysMountPoint = "/boot";
}
