{ config, pkgs, lib, ... }:

{
  systemd.user.services.swayvd = {
    enable = true;

    # [Unit]
    description = "a tool to set virtual display on Sway session";
    bindsTo     = [ "sway-session.target" ];
    before      = [ "wayvnc.service" ];

    # [Service]
    serviceConfig = {
      Type           = "oneshot";
      ExecStart      = "/run/current-system/sw/bin/swaymsg create_output HEADLESS-1"; 
    };

    # [Install]
    wantedBy = [ "sway-session.target" ];
  };
}
