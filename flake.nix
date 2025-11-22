{
  description = "Opti NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, disko, ... }: {
    nixosConfigurations = {
      opti = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/opti disko.nixosModules.disko ];
      };
    };
  };
}
