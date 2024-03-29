{ config, pkgs, lib, ... }:

let
  user = "nixos";
  password = "nix";
  group = "users";
  extraGroups = [ "wheel" "networkmanager" "docker" "video" "adbusers" "plugdev" ];
  hostId = "007f0200";
  hostname = "deskmini";
  allowedTCPPorts = [ 22 2002 3389 5900 6600 ];
  allowedUDPPorts = [ 22 2002 3389 5900 6600 ];
in
{
  imports = [ 
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # ./i3wm.nix
    ./sway.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostId = hostId;
    hostName = hostname;
    useDHCP = true;
  };

  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    allowedTCPPorts = allowedTCPPorts;
    allowedUDPPorts = allowedUDPPorts;
  };

  location = {
    latitude = 35.4;
    longitude = 139.6;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enabled = "fcitx5";
      # fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
      fcitx5.addons = with pkgs; [ fcitx5-mozc ];
    };
  };
  
  console = {
    font = "LatTerminus16";
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";
  services.timesyncd.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };

  fonts.fonts = with pkgs; [
    fira-code
    noto-fonts-cjk
    cooper-hewitt
    ibm-plex
    jetbrains-mono
    iosevka
    spleen
    powerline-fonts
    font-awesome
    nerdfonts
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    cmake
    gcc 
    gnumake 
    nodejs 
    cargo
    fzf 
    peco 
    tree
    git 
    gh 
    tig
    ghq
    vim
    neovim 
    vscode
    tmux 
    screen
    zellij
    wget
    zip
    unzip
    exa
    bat 
    fd
    procs 
    ripgrep
    termite
    alacritty
    wezterm
    screenfetch
    rofi
    conky
    nitrogen
    imv
    picom
    dunst
    ffmpeg
    parcellite
    networkmanagerapplet
    pavucontrol 
    volumeicon
    chromium
    firefox
    vivaldi
    vivaldi-ffmpeg-codecs
    # vivaldi-widevine
    tailscale
    apktool
    android-tools
    android-studio
    jetbrains.idea-community
    # nix
    nixos-option
    nixpkgs-lint
    nixpkgs-fmt
    nixfmt
  ];

  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };

  environment.pathsToLink = [ "/libexec" ];

  # Cleanup to preserve space
  nix.gc.automatic = true;
  nix.gc.options   = "--delete-order-than 7d";
  boot.cleanTmpDir = true;

  # Some programs need SUID wrappers, can be configured further or are
  # s remote desktoptarted in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  programs.bash.enableCompletion = true;
  programs.zsh.enable            = true;
  programs.fish.enable           = true;
  programs.ssh.startAgent        = true;
  programs.light.enable          = true;
  programs.java.enable           = true;
  programs.adb.enable            = true;
  
  qt5.platformTheme              = "qt5ct";

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable                 = true;
    ports                  = [ 2002 ];
    passwordAuthentication = false;
    permitRootLogin        = "no";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Graphics settings
  services.xserver.videoDrivers = [ "nouverau" ];
  hardware.opengl.driSupport32Bit = true;

  # Enable bluetooth.
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.redshift = {
    enable = true;
    brightness = {
      day   = "1";
      night = "0.8";
    };
    temperature = {
      day   = 5500;
      night = 3700;
    };
  };

  services.cron = {
    enable = true;
    systemCronJobs = [
      "* 22 * * * nixos cat /etc/nixos/configuration.nix > /home/nixos/ghq/github.com/kazu1192/nixos-configurations/deskmini/configuration.nix"
      "* 22 * * * nixos cat /etc/nixos/i3wm.nix          > /home/nixos/ghq/github.com/kazu1192/nixos-configurations/deskmini/i3wm.nix"
      "* 22 * * * nixos cat /etc/nixos/sway.nix          > /home/nixos/ghq/github.com/kazu1192/nixos-configurations/deskmini/sway.nix"
      "0 1 * * *  root  rtcwake -m off -s 28800"
    ];
  };

  services.tailscale.enable = true;

  security.sudo.enable = true;

  virtualisation.docker.enable = true;

  users.motd = "Hello NixOS!";
  users.users = {
    ${user} = {
      isNormalUser = true;
      createHome = true;
      password = password;
      group = group;
      extraGroups = extraGroups;
      shell = pkgs.zsh;
    };

    host = { # old user
      isNormalUser = true;
      password = password;
      group = group;
      extraGroups = extraGroups;
      shell = pkgs.zsh;
    };
  };

  # system.autoUpgrade.enable = true;
  # system.autoUpgrade.allowReboot = true;
  system.stateVersion = "22.05";
}
