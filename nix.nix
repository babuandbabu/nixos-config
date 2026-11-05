{ ... }:
{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    # Noctalia binary cache (same as in flake.nix, but permanent / system-wide)
    substituters = [ "https://noctalia.cachix.org" ];
    trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
  };

  # Allow unfree software (VS Code etc.)
  nixpkgs.config.allowUnfree = true;

  # Keep the disk tidy: weekly garbage collection of old generations
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}
