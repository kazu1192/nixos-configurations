{ config, pkgs, lib, ... }:

{
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    # videoDrivers = [ "intel" ];
    libinput.enable = true;

    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
      sddm.enable = true;
      defaultSession = "none+i3";
    };

    windowManager = {
      i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        extraPackages = with pkgs; [
          dmenu #application launcher most people use
          i3status # gives you the default i3 status bar
          i3lock #default i3 screen locker
          i3blocks #if you are planning on using i3blocks over i3status
        ];
      };
    };
  };

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "i3";

  xdg.mime.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
  };
  
  hardware.pulseaudio.enable = true;
}
