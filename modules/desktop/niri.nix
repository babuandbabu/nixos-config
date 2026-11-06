# Fallback session. Pick "niri" in SDDM if mango ever breaks.
# Uses your existing ~/.config/niri/config.kdl untouched.
{ ... }:
{
  programs.niri.enable = true;
}
