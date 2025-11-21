{
  description = "Opti NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, ... }@inputs: {
    nixosConfigurations = {
      opti = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ disko.nixosModules.disko ./hosts/opti ];
      };
    };
  };
}
