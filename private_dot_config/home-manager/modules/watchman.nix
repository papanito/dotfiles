{ config, pkgs, ... }:

let
  #socketPath = "${config.home.homeDirectory}/.cache/watchman-socket";
  socketDir = "/run/user/${toString config.home.uid}/watchman";
  #socketPath = "${socketDir}/sock";
  socketPath = "${config.home.homeDirectory}/.cache/watchman-socket";
in
{
  home = {
    packages = [ pkgs.watchman ];
    file.".watchman.json".text = builtins.toJSON {
      # Increase the limits for large Nix projects/node_modules
      "max_count_entries" = 200000;
      "fscache_size" = 200000;
    };
    sessionVariables = {
      WATCHMAN_SOCK = socketPath;
    };
  };

  # Ensure the directory exists before the socket starts
  systemd.user.tmpfiles.rules = [
    "d ${socketDir} 0700 papanito users - -"
  ];

  # 1. The Socket Unit
  systemd.user = {
    sockets.watchman = {
      Unit = {
        Description = "Watchman socket for socket activation";
      };
      Socket = {
        ListenStream = socketPath;
        # This ensures systemd passes the FD to Watchman
        Accept = false; 
      };
      Install = {
        WantedBy = [ "sockets.target" ];
      };
    };
    # The Service Unit
    services.watchman = {
      Unit = {
        Description = "Watchman file watching service (Socket Activated)";
        Requires = [ "watchman.socket" ];
        After = [ "network.target" ];
      };
      Service = {
        # Use the flag from your commit link
        ExecStart = "${pkgs.watchman}/bin/watchman --foreground --inetd";
        StandardInput = "socket";
        StandardOutput = "journal";
        Restart = "on-failure";
      };
    };
  };
}

