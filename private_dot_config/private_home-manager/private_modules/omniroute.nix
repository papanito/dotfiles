{ pkgs, lib, ... }:

{

  systemd.user.services.omniroute = {
    Unit = {
      Description = "OmniRoute AI gateway (local proxy on port 20128)";
      After = [ "network.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "/home/papanito/.local/share/npm/bin/omniroute";
      Environment = [
        "OMNIROUTE_HOST=127.0.0.1"
        "OMNIROUTE_PORT=20128"
      ];
      Restart = "on-failure";
      RestartSec = 5;
      TimeoutStartSec = 30;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}

