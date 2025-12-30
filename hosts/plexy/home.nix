{ pkgs, ... }:

{
  home.username = "wekuz";
  home.homeDirectory = "/home/wekuz";

  home.packages = with pkgs; [
    neofetch

    # Utilities
    neovim
    tmux
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
