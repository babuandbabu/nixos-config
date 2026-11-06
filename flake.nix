# flake.nix — the entry point. It does two things:
#   1. `inputs`  : lists every external dependency (pinned in flake.lock).
#   2. `outputs` : builds the NixOS system called "desktop" from those inputs.
#
# Build it with:  sudo nixos-rebuild switch --flake .#desktop
{
  description = "NixOS: MangoWM + Noctalia v5 + SDDM Astronaut (no Home Manager)";

  inputs = {
    # Main package set. nixos-unstable is what both MangoWM and Noctalia document;
    # MangoWM needs a recent wlroots/scenefx that stable branches may lack.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # MangoWM compositor (repo moved from DreamMaoMao/mangowc to mangowm/mango).
    # Provides a NixOS module: nixosModules.mango  ->  programs.mango.enable
   # mangowm = {
   #   url = "github:mangowm/mango";
   #   inputs.nixpkgs.follows = "nixpkgs"; # reuse OUR nixpkgs instead of a second copy
   # };

    # Noctalia v5 shell (native C++ rewrite, binary: `noctalia`).
    # Only exposes a package (packages.<system>.default) for plain NixOS use;
    # its module is Home-Manager-only, which we deliberately do not use.
    #noctalia = {
     noctalia.url = "github:noctalia-dev/noctalia";
      #inputs.nixpkgs.follows = "nixpkgs";
    #};
  };

  # Noctalia's binary cache, so you download instead of compiling the shell.
  # Use `--accept-flake-config` on the very first build (modules/system/nix.nix
  # makes it permanent afterwards).
  #nixConfig = {
   # extra-substituters = [ "https://noctalia.cachix.org" ];
    #extra-trusted-public-keys = [
     # "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    #];
  #};

 # outputs = { self, nixpkgs, mangowm, noctalia, ... }@inputs: {
outputs = { self, nixpkgs,noctalia, ... }@inputs: {
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      # `inputs` is passed to every module so they can write inputs.noctalia etc.
      specialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.hostPlatform = "x86_64-linux"; }
        #mangowm.nixosModules.mango # adds the `programs.mango.*` options
        ./hosts/desktop
      ];
    };
  };
}
