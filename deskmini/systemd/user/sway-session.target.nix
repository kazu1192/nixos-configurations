{ config, pkgs, lib, ... }:

{
  systemd.user.targets.sway-session = {
    enable = true;

    # [Unit]
    description   = "Sway compositor session";
    documentation = [ "man:systemd.special" ];
    bindsTo       = [ "graphical-session.target" ];
    wants         = [ "graphical-session-pre.target" ];
    after         = [ "graphical-session-pre.target" ];
  };
}
