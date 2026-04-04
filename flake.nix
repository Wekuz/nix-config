{
  description = "Wekuz's NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gpgKey = {
      url = "https://keys.openpgp.org/vks/v1/by-email/wekuz%40duck.com";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      sops-nix,
      disko,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        plexy = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/plexy
            {
              nixpkgs = {
                overlays = [
                  (final: prev: {
                    unstable = import nixpkgs-unstable {
                      system = final.system;
                    };
                  })
                ];
              };
            }
            (import "${nixpkgs-unstable}/nixos/modules/services/misc/seerr.nix")
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.wekuz = import ./hosts/plexy/home.nix;
            }
            sops-nix.nixosModules.sops
            disko.nixosModules.disko
          ];
        };
      };
    };
}
