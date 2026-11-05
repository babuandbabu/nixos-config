{ ... }:
{
  networking.networkmanager.enable = true;

  networking.firewall = {
    enable = true;
    # LocalSend discovery + transfer port
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };
}
