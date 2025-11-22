{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  networking = {
    hostName = "opti";
    networkmanager.enable = true;
    firewall.enable = false; # TODO: Configure firewall
  };

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [ git ];

  users.users.wekuz = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBs3aPxyJpVGytuVSO3va2WybKNFMR241o8DCJQbBEWV"
    ];
  };

  system.stateVersion = "25.05";
}
