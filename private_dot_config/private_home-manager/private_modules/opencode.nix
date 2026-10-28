{ pkgs, lib, ... }:

{
  systemd.user.services.opencode-server = {
    Unit = {
      Description = "OpenCode headless AI coding agent server on port 4096";
      After = [ "network.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.opencode}/bin/opencode serve --hostname 127.0.0.1 --port 4096";
      Restart = "on-failure";
      RestartSec = 5;
      TimeoutStartSec = 30;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
