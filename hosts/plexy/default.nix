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
      intel-media-driver # VAAPI
      intel-compute-runtime # OpenCL
      libvdpau-va-gl # VDPAU
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
      5055 # Seerr
      5201 # iperf3
      8096 # Jellyfin
      15835 # Glance
      15836 # qBittorrent (Web UI)
      15837 # Radarr
      15838 # Sonarr
      17650 # qBittorrent (torrent)
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
          torrents = {
            path = "/storage/torrents";
            comment = "Torrents storage";
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
    seerr = {
      enable = true;
      package = pkgs.unstable.seerr;
    };
    qbittorrent = {
      enable = true;
      torrentingPort = 17650;
      webuiPort = 15836;
      serverConfig = {
        Application.FileLogger = {
          Enabled = true;
          Path = "/var/log/qBittorrent";
          Backup = true;
          MaxSizeBytes = 65536;
          DeleteOld = true;
          Age = 14;
          AgeType = 0;
        };
        BitTorrent.Session = {
          AddTorrentStopped = false;
          Preallocation = true;
          AddExtensionToIncompleteFiles = false;
          DisableAutoTMMByDefault = false;

          MaxConnections = 1000;
          MaxConnectionsPerTorrent = 200;
          MaxUploads = 64;
          MaxUploadsPerTorrent = 26;

          GlobalDLSpeedLimit = 6000;
          GlobalUPSpeedLimit = 6000;
          AlternativeGlobalDLSpeedLimit = 0;
          AlternativeGlobalUPSpeedLimit = 0;
          BandwidthSchedulerEnabled = true;
          DefaultSavePath = "/storage/torrents";

          MaxActiveCheckingTorrents = 1;

          QueueingSystemEnabled = true;
          MaxActiveDownloads = 3;
          MaxActiveUploads = 10;
          MaxActiveTorrents = 200;
          IgnoreSlowTorrentsForQueueing = true;
          SlowTorrentsDownloadRate = 500;
          SlowTorrentsUploadRate = 100;
          SlowTorrentsInactivityTimer = 60;

          GlobalMaxRatio = -1;
          GlobalMaxSeedingMinutes = -1;
          GlobalMaxInactiveSeedingMinutes = -1;
          ShareLimitAction = "Stop";

          Interface = "";
          InterfaceAddress = "";
          InterfaceName = "";
        };
        Network = {
          PortForwardingEnabled = false;
        };
        Preferences = {
          General = {
            Locale = "en";
            StatusbarExternalIPDisplayed = true;
          };
          Scheduler = {
            end_time = "@Variant(\\0\\0\\0\\xf\\x1\\x65\\xe@)"; # 02:00
            start_time = "@Variant(\\0\\0\\0\\xf\\0m\\xdd\\0)"; # 06:30
          };
          WebUI = {
            Address = "*";
            Username = "admin";
            Password_PBKDF2 = "@ByteArray(IM7ih6pLNXBv6it48lI1Lg==:VyczL0q0C89RNfXkzcvdZemfXjdG53xBSY66gqIl56dA0OcrvvxOQdW8jOzvY3lFjR+WDBG3Q/ejsG4w8O5RRA==)";
            LocalHostAuth = false;
          };
        };
        Core.AutoDeleteAddedTorrentFile = "never";
        LegalNotice.Accepted = true;
      };
    };
    radarr = {
      enable = true;
      settings = {
        server.port = 15837;
      };
    };
    sonarr = {
      enable = true;
      settings = {
        server.port = 15838;
      };
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
      qbittorrent = {
        extraGroups = [
          "media"
        ];
      };
      radarr = {
        extraGroups = [
          "media"
        ];
      };
      sonarr = {
        extraGroups = [
          "media"
        ];
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /storage 0755 root root -"
    "d /storage/media 2775 wekuz media -"
    "d /storage/media/movies 2775 wekuz media -"
    "d /storage/media/tv 2775 wekuz media -"
    "d /storage/torrents 2775 wekuz media -"
  ];

  system.stateVersion = "25.11";
}
