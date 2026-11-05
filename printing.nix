# Optional. Enable by uncommenting the import in configuration.nix.
{ ... }:
{
  services.printing.enable = true;
  services.avahi = { enable = true; nssmdns4 = true; openFirewall = true; };
}
