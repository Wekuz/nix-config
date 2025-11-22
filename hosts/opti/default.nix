{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ./disko-config.nix ];

  nix = {
    package = pkgs.nixVersions.stable;

    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    extraOptions = ''
      min-free = 512000000
      max-free = 2000000000
    '';
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver vaapiIntel ];
  };

  time.timeZone = "Europe/Tallinn";

  networking = {
    hostName = "opti";
    networkmanager.enable = true;
    useDHCP = true;
    firewall.allowedTCPPorts = [ 22 ];
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    git
    btop
    ncdu
    tmux
    wget
    ripgrep
    smartmontools
    lm_sensors
  ];

  environment.variables.EDITOR = "nvim";

  users.users.wekuz = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBs3aPxyJpVGytuVSO3va2WybKNFMR241o8DCJQbBEWV"
    ];
  };

  system.stateVersion = "25.05";
}
