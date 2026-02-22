{ config, ... }:

let
  # Direct path to the binary based on your structure
  hazelnutBin = "${config.home.homeDirectory}/.local/share/cargo/bin/hazelnutd";
in
{
  services.pueue = {
    enable = true;
    # Optional: Configure the daemon behavior
    settings = {
      shared = {
        # Use a custom socket path if desired, defaults to $XDG_RUNTIME_DIR/pueue.socket
        # use_unix_socket = true;
      };
      daemon = {
        default_parallel_tasks = 2;
      };
    };
  };
  systemd.user.services.hazelnut = {
    Unit = {
      Description = "Hazelnut Daemon (Cargo)";
      After = [ "network.target" ];
      ConditionPathExists = hazelnutBin;
    };

    Service = {
      # systemd requires absolute paths for ExecStart
      ExecStart = "${hazelnutBin} start";
      
      # Ensure the daemon sees the same CARGO_HOME as your shell
      # Even if set globally, systemd units often need explicit environment hints
      Environment = [
        "CARGO_HOME=${config.home.homeDirectory}/.local/share/cargo"
        "PATH=${config.home.homeDirectory}/.local/share/cargo/bin:%h/.nix-profile/bin:/run/current-system/sw/bin"
      ];

      Restart = "on-failure";
      RestartSec = "5s";
    };

    Install = {
      # This ensures the daemon starts on user login
      WantedBy = [ "default.target" ];
    };
  };
}

