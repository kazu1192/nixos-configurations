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
    fzf peco tree
    git gh tig ghq
    vim neovim 
    vscode
    tmux screen zellij
    wget zip unzip
    exa bat fd procs ripgrep
    termite alacritty
    zsh fish screenfetch
    rofi conky nitrogen picom
    dunst parcellite volumeicon
    chromium firefox vivaldi
    vivaldi-ffmpeg-codecs
    # vivaldi-widevine
    tailscale
    apktool android-tools android-studio
    jetbrains.idea-community
  ];

  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };

  environment.pathsToLink = [ "/libexec" ];

  # Cleanup to preserve space
  nix.gc.automatic = true;
  nix.gc.options = "--delete-order-than 7d";
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
  programs.ssh.startAgent = true;
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
      "* 22 * * * nixos cat /etc/nixos/configuration.nix > /home/nixos/ghq/github.com/kazu1192/nixos-configurations/deskmini/configuration.nix"
      "* 22 * * * nixos cat /etc/nixos/i3wm.nix          > /home/nixos/ghq/github.com/kazu1192/nixos-configurations/deskmini/i3wm.nix"
      "* 22 * * * nixos cat /etc/nixos/sway.nix          > /home/nixos/ghq/github.com/kazu1192/nixos-configurations/deskmini/sway.nix"
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

  system.stateVersion = "22.05";
}
