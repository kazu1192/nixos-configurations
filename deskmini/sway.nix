{ config, pkgs, lib, ... }:

let
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;
    text = ''
      dbus-update-activation-environment --systemd WAYLAND-DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk"; 
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Dracula'
    '';
  };
in
{
  imports = [ 
    ./systemd/user/sway-session.target.nix
    ./systemd/user/swayvd.service.nix
    ./systemd/user/wayvnc.service.nix
  ];

  environment.sessionVariables = {
    GTK_USE_PORTAL = "1";
  };

  # enable sway window manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
    extraPackages = with pkgs; [
      dbus-sway-environment
      configure-gtk
      wofi
      wayvnc # remote desktop
      glib # gsettings
      dracula-theme # gtk theme
      waybar
      swaylock
      swayidle
      grim # sceenshot functionality
      slurp # screenshot functionality
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      bemenu # wayland clone on dmenu
      mako # notification system developed by swaywm manitainer
    ];
    extraSessionCommands = ''
      export _JAVA_AWT_WM_NONREPARENTING="1"
      export MOZ_ENABLE_WAYLAND="1"; # Firefox
      export GDK_BACKEND="x11 code";
      export WINIT_UNIT_BACKEND="x11";
    '';
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.dbus.enable = true;

  services.xserver.enable = true;
  services.xserver.displayManager = {
    lightdm.enable = true;
    defaultSession = "sway";
    autoLogin = {
      enable = true;
      user = "nixos";
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
