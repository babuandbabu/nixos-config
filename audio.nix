# PipeWire replaces PulseAudio/JACK; WirePlumber is its session manager
# (provides `wpctl`, used by your volume keybinds).
{ pkgs, ... }:
{
  security.rtkit.enable = true; # lets PipeWire get realtime priority
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;        # PulseAudio compatibility (pamixer, apps)
    wireplumber.enable = true;
  };
  environment.systemPackages = [ pkgs.wireplumber ]; # make sure `wpctl` is in PATH
}
