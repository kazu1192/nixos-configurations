{ config, pkgs, lib, ...}:

let
  user = "nixos";
  password = "nix";
  hostId = "b6c232ed";
  hostname = "raspberry3p";
  eth0Address = "";
  wlan0Address = "";
  defaultGateway = "";
  nameservers = [ "1.1.1.1" "8.8.8.8" ];
  SSID = "";
  SSIDpassword = "";
  allowedTCPPorts = [ 22 80 443 2002 6600 ];
  allowedUDPPorts = [ 22 80 443 2002 6600 ];
in {
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "cma=256M" 
    "console=ttyS1,115200n8"
  ];

  # raspberryPi /boot/config
  boot.loader.raspberryPi.firmwareConfig = ''
    dtparam=audio=on
  '';

  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.initrd.availableKernelModules = [ "usb_storage" "usbhid" ];
  boot.supportedFilesystems = [ "zfs" ];

  nixpkgs.config.allowBroken = true;

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
  '';

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

    "/nas/data" = {
      device = "nas/data";
      fsType = "zfs";
      options = [ "nofail" "x-systemd.device-timeout=1" ];
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
    gptfdisk zfs
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
    hostId = hostId;
    hostName = hostname;
    dhcpcd.enable = true;
    usePredictableInterfaceNames = false;

    interfaces.eth0.ipv4.addresses = [{
      address = eth0Address;
      prefixLength = 24;
    }];

    interfaces.wlan0.ipv4.addresses = [{
      address = wlan0Address;
      prefixLength = 24;
    }];

    wireless.enable = false;
    wireless.interfaces = [ "wlan0" ];
    wireless.networks."${SSID}".psk = "${SSIDpassword}"; 

    defaultGateway.address = defaultGateway;
    nameservers = nameservers;
  };

  networking.firewall = {
    enable = false;
    allowPing = true;
    allowedTCPPorts = allowedTCPPorts;
    allowedUDPPorts = allowedTCPPorts;
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
