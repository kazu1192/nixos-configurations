{ config, pkgs, lib, ...}:

{
  # zfs
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.initrd.availableKernelModules = [ "usb_storage" "usbhid" ];
  boot.supportedFilesystems = [ "zfs" ];

  nixpkgs.config.allowBroken = true;

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
  '';

  fileSystems."/nas/data" = {
    device = "nas/data";
    fsType = "zfs";
    options = [ "nofail" "x-systemd.device-timeout=1" ];
  };
}
