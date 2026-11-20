{ config, pkgs, ... }:

let
  socketPath = "${config.home.homeDirectory}/.cache/watchman-socket";
in
{
  home = {
    packages = [ pkgs.watchman ];
    # Tuning lives in the system-wide /etc/watchman.json (profiles/pc in
    # nixos-configuration). Do not add ~/.watchman.json here: watchman only
    # reads $WATCHMAN_CONFIG_FILE or /etc/watchman.json plus <root>/.watchmanconfig,
    # and a ~/.watchmanconfig would turn $HOME into a watch-project root.
    sessionVariables = {
      WATCHMAN_SOCK = socketPath;
    };
  };

  # The Socket Unit
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

