{ pkgs, lib, ... }:

{
  # OmniRoute — free AI gateway (231+ providers, one endpoint on port 20128)
  # The upstream flake (github:diegosouzapw/OmniRoute) only exposes a devShell,
  # no package output, so we install via npm and run as a user systemd service.
  home.packages = [ pkgs.nodejs_22 ];

  systemd.user.services.omniroute = {
    Unit = {
      Description = "OmniRoute AI gateway (local proxy on port 20128)";
      After = [ "network.target" ];
    };

    Service = {
      Type = "simple";
      # omniroute with no subcommand serves the gateway + dashboard on port 20128
      ExecStart = "${pkgs.nodejs_22}/bin/npx --yes omniroute";
      Environment = [
        "PATH=${pkgs.nodejs_22}/bin:$PATH"
        "OMNIROUTE_HOST=127.0.0.1"
        "OMNIROUTE_PORT=20128"
      ];
      Restart = "on-failure";
      RestartSec = 5;
      # Give it time to npm-fetch on first start
      TimeoutStartSec = 120;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}