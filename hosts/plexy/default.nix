{
  config,
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
    timeout = 0;
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
      873 # rsyncd
      5201 # iperf3
      8096 # Jellyfin
      15835 # Glance
    ];
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/var/lib/sops-nix/key.txt";
    age.sshKeyPaths = [ ];
    gnupg.sshKeyPaths = [ ];

    secrets = {
      "vaultwarden.env" = { };
      "rsyncd.secrets" = { };
    };
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.PermitRootLogin = "no";
    };
    iperf3 = {
      enable = true;
    };
    rsyncd = {
      enable = true;
      settings = {
        globalSection = {
          address = "0.0.0.0";
          gid = "users";
          "max connections" = 5;
          uid = "wekuz";
        };
        sections = {
          media = {
            path = "/storage/media";
            comment = "Media storage";
            "read only" = false;
            "auth users" = "wekuz";
            "secrets file" = config.sops.secrets."rsyncd.secrets".path;
          };
        };
      };
    };
    vaultwarden = {
      enable = true;
      environmentFile = config.sops.secrets."vaultwarden.env".path;
      config = {
        WEBSOCKET_ENABLED = true;
        SIGNUPS_ALLOWED = false;
        SIGNUPS_VERIFY = false;
        INVITATIONS_ALLOWED = false;
        SHOW_PASSWORD_HINT = false;
        DATA_FOLDER = "/var/lib/vaultwarden/data";
        LOG_LEVEL = "warn";
      };
    };
    glance = {
      enable = true;
      settings = import ./glance.nix;
    };
    jellyfin = {
      enable = true;
    };
  };

  environment.variables.EDITOR = "nvim";

  users = {
    groups = {
      media = { };
    };
    users = {
      wekuz = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "docker"
          "media"
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBs3aPxyJpVGytuVSO3va2WybKNFMR241o8DCJQbBEWV"
        ];
      };
      jellyfin = {
        extraGroups = [
          "media"
        ];
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /storage 0755 root root -"
    "d /storage/media 2775 wekuz media -"
  ];

  system.stateVersion = "25.11";
}
