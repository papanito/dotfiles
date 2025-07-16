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
      #package = pkgs.gnome.adwaita-icon-theme;
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

  dconf.settings = {
    "apps/guake/general" = {
      compat-delete = "delete-sequence";
      display-n = 0;
      display-tab-names = 0;
      gtk-use-system-default-theme = true;
      hide-tabs-if-one-tab = false;
      history-size = 1000;
      load-guake-yml = true;
      max-tab-name-length = 100;
      mouse-display = true;
      open-tab-cwd = true;
      prompt-on-quit = true;
      quick-open-command-line = "gedit %(file_path)s";
      restore-tabs-notify = true;
      restore-tabs-startup = true;
      save-tabs-when-changed = false;
      schema-version = "3.9.0";
      scroll-keystroke = true;
      start-at-login = true;
      use-default-font = true;
      use-popup = true;
      use-scrollbar = true;
      use-trayicon = true;
      window-halignment = 0;
      window-height = 50;
      window-losefocus = false;
      window-refocus = false;
      window-tabbar = true;
      window-width = 100;
    };
    "apps/guake/keybindings/global" = {
      show-hide = "F12";
    };
    "apps/guake/style/background" = {
      transparency = 90;
    };
    "apps/guake/style/font" = {
      allow-bold = true;
      palette = "#000027273131:#D0D01B1B2424:#727289890505:#A5A577770505:#20207575C7C7:#C6C61B1B6E6E:#252591918585:#E9E9E2E2CBCB:#00001E1E2626:#BDBD36361212:#46465A5A6161:#525267676F6F:#707081818383:#58585656B9B9:#818190908F8F:#FCFCF4F4DCDC:#707081818383:#00001E1E2626";
      palette-name = "Solarized Dark";
    };
    "apps/seahorse" = {
      server-auto-publish = true;
      server-auto-retrieve = true;
      server-publish-to = "hkps://keys.openpgp.org";
    };
    "com/gexperts/Tilix" = {
      terminal-title-style = "small";
      theme-variant = "dark";
      use-tabs = false;
      warn-vte-config-issue = false;
      window-style = "normal";
    };
    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };
    "org/gnome/desktop/calendar" = {
      show-weekdate = true;
    };
    "org/gnome/desktop/datetime" = {
      automatic-timezone = true;
    };
    "org/gnome/desktop/interface" = {
      clock-show-seconds = true;
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      cursor-blink = true;
      cursor-blink-time = 1000;
      cursor-size = 24;
      cursor-theme = "Adwaita";
      enable-animations = true;
      font-antialiasing = "rgba";
      font-hinting = "slight";
      font-name = "Noto Sans,  10";
      gtk-theme = "Adwaita";
      icon-theme = "Adwaita";
      show-battery-percentage = true;
      text-scaling-factor = 1.0;
      toolbar-style = "text";
      enable-hot-corners = true;
    };
    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
    };
    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "adaptive";
      speed = 1.0;
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      click-method = "fingers";
      edge-scrolling-enabled = false;
      send-events = "enabled";
      speed = 0.39097744360902253;
      tap-to-click = false;
      two-finger-scrolling-enabled = true;
    };
    "org/gnome/desktop/privacy" = {
      old-files-age = "uint32 30";
      recent-files-max-age = -1;
      remove-old-temp-files = true;
      remove-old-trash-files = true;
    };
    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      idle-activation-enabled = true;
      picture-options = "zoom";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };
    "org/gnome/desktop/session" = {
      idle-delay = "uint32 900";
    };
    "org/gnome/desktop/sound" = {
      event-sounds = false;
      theme-name = "ocean";
    };
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "icon:minimize,maximize,close";
      focus-mode = "click";
    };
    "org/gnome/mutter" = {
      attach-modal-dialogs = true;
      dynamic-workspaces = true;
      edge-tiling = true;
      workspaces-only-on-primary = true;
    };
    "org/gnome/shell" = {
      disable-extension-version-validation = true;
      disable-user-extensions = false;
    };
    "org/gnome/system/location" = {
      enabled = true;
    };
    "system/locale" = {
      region = "de_CH.UTF-8";
    };
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
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
  };
}