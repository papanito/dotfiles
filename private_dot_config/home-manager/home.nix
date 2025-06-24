{  pkgs, lib, config, security, ... }:
let 
    mountdir_yunohost = "${config.home.homeDirectory}/cs/yuno";
in
{
  home = {
    username = "papanito";
    homeDirectory = "/home/papanito";
  };

  # modules
  gnome.enable = false;
  kde.enable = true;

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  home.packages = with pkgs; [
    sshfs
    pueue
  ];

  systemd.user = {
    mounts = {
      mount-yunohost = {
          Unit = {
              Description = "mount yunohost home";
          };
          Mount = {
            What="adrian@yuno.home:/home";
            Where="${mountdir_yunohost}";
            Type="sshfs";
            Options="x-systemd.automount,_netdev,reconnect,allow_other,identityfile=/home/papanito/.ssh/id_rsa";
            #SloppyOptions=
            #LazyUnmount=
            #ReadWriteOnly=
            #ForceUnmount=
            #DirectoryMode=
            #TimeoutSec=
          };
      };
    };
    # services = {
    #   pueued = {
    #     enable = true;
    #     description = "Pueue daemon";

    #     # wantedBy = [ "multi-user.target" ];

    #     # restartIfChanged = true; # set to false, if restarting is problematic

    #     # serviceConfig = {
    #     #   DynamicUser = true;
    #     #   ExecStart = "/run/current-system/sw/bin/pueued -dv";
    #     #   Restart = "always";
    #     # };
    #   };
    # };
  };

 
  
}