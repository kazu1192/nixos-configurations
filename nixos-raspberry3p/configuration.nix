{ config, pkgs, lib, ...}:

let
  user = "nixos";
  password = "nix";
  SSID = "";
  SSIDpassword = "";
  interface = "";
  hostname = "nixos-raspberry3p";
in {
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "cma=256M" 
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  swapDevices = [{ device = "/swapfile"; size = 1024; }];

  environment.systemPackages = with pkgs; [
    curl wget 
    zip unzip rsync tree
    exa bat fd procs ripgrep
    fzf peco
    git gh tig ghq
    vim neovim 
    zellij screen tmux
    tailscale
    libraspberrypi
  ];

  environment.variables.EDITOR = "vim";

  programs = {
    bash.enableCompletion = true;
    ssh.startAgent = true;
  };

  # Cleanup to preserve space on the SD
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 7d";
  boot.cleanTmpDir = true;

  documentation.nixos.enable = false;

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
  };

  services.timesyncd.enable = true;
  time.timeZone = "Asia/Tokyo";

  services.mpd = {
    enable = true;
    musicDirectory = "/var/music";
    extraConfig = ''
      audio_output {
        type "alsa"
        name "My ALSA"
        device        "hw:1,0"
        format        "44100:16:2"
        mixer_type    "hardware"
        mixer_device  "default"
        mixer_control "PCM"
      }
    '';
    network.listenAddress = "any";
    startWhenNeeded = true;
  };

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
  };

  networking = {
    interfaces.wlan0 = {
      useDHCP = true;
    };

    interfaces.eth0 = {
      useDHCP = true;
    };

    hostName = hostname;

    wireless.enable = true;
    wireless.interfaces = [ interface ];
    wireless.networks."${SSID}".psk = "${SSIDpassword}"; 
  };

  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [];
    allowedUDPPorts = [];
  };

  users = {
    mutableUsers = true;
    users.${user} = {
      isNormalUser = true;
      password = password;
      extraGroups = [ "wheel" "docker" ];
    };
  };

  # Audio
  sound.enable = true;

  # Docker
  virtualisation.docker.enable = true;

  system.stateVersion = "22.05";
}
