{ config, pkgs, lib, ... }:

let
   cfg = config.gnome;
in
{
  options.gnome = {
    enable 
      = lib.mkEnableOption "enable gnome and install relatedd software";
  };
  config = lib.mkIf cfg.enable {

 gtk = {
    enable = true;

    # iconTheme = {
    #   name = "Papirus-Dark";
    #   package = pkgs.papirus-icon-theme;
    # };

    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };
  
    theme = {
      name = "Adwaita";
      # package = pkgs.palenight-theme;
    };

    cursorTheme = {
      name = "Adwaita";
      # package = pkgs.numix-cursor-theme;
    };

    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };

    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  #home.sessionVariables.GTK_THEME = "palenight";
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = true;
    };
  };

  # dconf.settings = {
  #   "org/gnome/shell" = {
  #     disable-user-extensions = false;

  #     # `gnome-extensions list` for a list
  #     # enabled-extensions = [
  #     #   "user-theme@gnome-shell-extensions.gcampax.github.com"
  #     #   "trayIconsReloaded@selfmade.pl"
  #     #   "Vitals@CoreCoding.com"
  #     #   "dash-to-panel@jderose9.github.com"
  #     #   "sound-output-device-chooser@kgshank.net"
  #     #   "space-bar@luchrioh"
  #     # ];

  #     favorite-apps = [
  #       "firefox.desktop"
  #       "code.desktop"
  #       "org.gnome.Terminal.desktop"
  #       "spotify.desktop"
  #       "virt-manager.desktop"
  #       "org.gnome.Nautilus.desktop"
  #     ];
  #   };
 
    # "org/gnome/desktop/wm/preferences" = {
    #   workspace-names = [ "Main" ];
    # };
    # "org/gnome/desktop/background" = {
    #   picture-uri = "file:////home/papanito/.local/share/backgrounds/2023-09-09-16-28-03-landscape-wallpapers-1.jpg";
    #   picture-uri-dark = "file:////home/papanito/.local/share/backgrounds/2023-09-09-16-28-03-landscape-wallpapers-1.jpg";
    # };
    # "org/gnome/desktop/screensaver" = {
    #   picture-uri = "file:////home/papanito/.local/share/backgrounds/2023-09-09-16-28-03-landscape-wallpapers-1.jpg";
    #   primary-color = "#3465a4";
    #   secondary-color = "#000000";
    # };

  }
}