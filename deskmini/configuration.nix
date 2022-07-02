{ config, pkgs, callPackage, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # ./i3wm.nix
      ./sway.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "nixox-dm";
    useDHCP = false;
    interfaces = {
      wlp2s0.useDHCP = true;
    };
    networkmanager.enable = true;
  };

  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    allowedTCPPorts = [ 22 2002 3389 6600 ];
    allowedUDPPorts = [ 22 2002 6600 ];
  };

  location = {
    latitude = 35.4;
    longitude = 139.6;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enabled = "fcitx";
      fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
    };
  };
  
  console = {
    font = "LatArCyrHeb-16";
    keyMap = "us";
  };

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      fira-code
      fira-code-symbols
      font-awesome
      nerdfonts
    ];
  };

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";
  services.timesyncd.enable = true;

  # Cleanup to preserve space
  nix.gc.automatic = true;
  nix.gc.options = "--delete-order-than 7d";
  boot.cleanTmpDir = true;

  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nixos-option
    pavucontrol ffmpeg
    networkmanagerapplet
    cmake gcc gnumake nodejs cargo
    git gh tig ghq
    vim neovim 
    tmux zellij
    wget zip unzip
    exa bat fd procs ripgrep
    fzf peco tree
    termite alacritty
    zsh fish screenfetch
    rofi conky nitrogen picom
    dunst parcellite volumeicon
    chromium firefox vivaldi
    vivaldi-ffmpeg-codecs
    # vivaldi-widevine
    tailscale
    vscode
    apktool android-tools android-studio
    jetbrains.idea-community
  ];

  environment.pathsToLink = [ "/libexec" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  programs.light.enable = true;
  programs.java.enable = true;
  programs.adb.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 2002 ];
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;

  # Enable bluetooth.
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.redshift = {
    enable = true;
    brightness = {
      # Note the string values below.
      day = "1";
      night = "0.8";
    };
    temperature = {
      day = 5500;
      night = 3700;
    };
  };

  services.cron = {
    enable = true;
    systemCronJobs = [
      "* 23 * * *  root  cat /etc/nixos/configuration.nix > /home/host/.dotfiles/nixos/configuration.nix"
    ];
  };

  services.tailscale.enable = true;

  security.sudo.enable = true;

  virtualisation.docker.enable = true;

  users.motd = "Hello NixOS!";
  users.users = {
    host = {
      isNormalUser = true;
      createHome = true;
      password = "nix";
      group = "users";
      extraGroups = [ "wheel" "networkmanager" "docker" "video" "adbusers" "plugdev" ];
      shell = pkgs.zsh;
    };
    nixos = {
      isNormalUser = true;
      createHome = true;
      password = "nix";
      group = "users";
      extraGroups = [ "wheel" "networkmanager" "docker" "video" "adbusers" "plugdev" ];
      shell = pkgs.zsh;
    };
  };

  system.stateVersion = "22.05";
}
