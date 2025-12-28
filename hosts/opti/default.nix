{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ./disko-config.nix ];

  nix = {
    package = pkgs.nixVersions.stable;

    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 2w";
    };
    settings.experimental-features = [ "nix-command" "flakes" ];

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
    nftables.enable = true;
    firewall.allowedTCPPorts = [ 22 80 443 ];
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
        randomizedDelaySec = "30min";
        flags = [ "--all" "--volumes" ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    git
    neovim
    btop
    ncdu
    tmux
    wget
    iperf3
    dnsutils
    file
    which
    zstd
    zip
    xz
    unzip
    ripgrep
    smartmontools
    lm_sensors
    ethtool
    fastfetch
  ];

  environment.variables.EDITOR = "nvim";

  users.users.wekuz = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBs3aPxyJpVGytuVSO3va2WybKNFMR241o8DCJQbBEWV"
    ];
  };

  system.stateVersion = "25.05";
}
