{ pkgs, inputs, ... }:

{
  home.username = "wekuz";
  home.homeDirectory = "/home/wekuz";

  home.packages = with pkgs; [
    fastfetch

    # Utilities
    neovim
    tmux
    gnupg
    zip
    xz
    unzip
    p7zip
    zstd
    ripgrep
    file
    which
    btop
    ncdu
    lm_sensors
    pciutils
    usbutils
    smartmontools

    # Networking
    mtr
    iperf3
    wget
    dnsutils
    ldns
    ethtool
  ];

  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        source = "${inputs.gpgKey}";
        trust = 5;
      }
    ];
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Wekuz";
        email = "wekuz@duck.com";
      };
      init.defaultBranch = "main";
    };
  };

  programs.zsh = {
    enable = true;
  };

  home.stateVersion = "25.11";
}
