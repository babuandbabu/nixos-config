# Noctalia's control center talks to BlueZ directly; no extra GUI needed.
{ ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
}
