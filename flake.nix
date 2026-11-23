
{
  description = "NixOS: MangoWM + Noctalia + SDDM";

  inputs = {
    # Main system
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Separate unstable package set
    nixpkgs-unstable.url =
      "github:NixOS/nixpkgs/nixos-unstable";

    # MangoWM
    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Noctalia
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };

      modules = [
        {
          nixpkgs.hostPlatform = "x86_64-linux";
        }

        ./hosts/desktop
      ];
    };
  };
}
