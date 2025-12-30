{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  nix = {
    package = pkgs.nixVersions.stable;

    optimise = {
      automatic = true;
      dates = "Mon *-*-* 03:00:00";
      randomizedDelaySec = "10m";
    };
    gc = {
      automatic = true;
      dates = "Mon *-*-* 03:00:00";
      randomizedDelaySec = "10m";
      options = "--delete-older-than 7d";
    };
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    extraOptions = ''
      min-free = 512000000
      max-free = 2000000000
    '';
  };

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 8;
    };
    efi.canTouchEfiVariables = true;
    timeout = 1;
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
    ];
  };

  time.timeZone = "Europe/Tallinn";

  networking = {
    hostName = "plexy";
    networkmanager.enable = true;
    nftables.enable = true;
    firewall.allowedTCPPorts = [
      22
      80
      443
    ];
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/var/lib/sops-nix/key.txt";
    age.sshKeyPaths = [ ];
    gnupg.sshKeyPaths = [ ];

    secrets = { };
  };

  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.PermitRootLogin = "no";
    };
  };

  environment.variables.EDITOR = "nvim";

  users.users.wekuz = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBs3aPxyJpVGytuVSO3va2WybKNFMR241o8DCJQbBEWV"
    ];
  };

  system.stateVersion = "25.11";
}
