{ config, pkgs, lib, ... }:

{
  systemd.user.services.wayvnc = {
    enable = true;

    # [Unit]
    description = "A VNC server for wlroots base Wayland compositors";
    bindsTo     = [ "sway-session.target" ];
    requires    = [ "swayvd.service" ];
    after       = [ "swayvd.service" ];

    # [Service]
    serviceConfig = {
      Type           = "simple";
      ExecStart      = "/run/current-system/sw/bin/wayvnc --output=HEADLESS-1"; 
      Restart        = "always";
      RestartSec     = "1";
      TimeoutStopSec = "10";
    };

    # [Install]
    wantedBy = [ "sway-session.target" ];
  };
}
