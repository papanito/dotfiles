{ config, pkgs, ... }:

let
  # Direct path to the binary based on your structure
  hazelnutBin = "${config.home.homeDirectory}/.local/share/cargo/bin/hazelnutd";
in
{
  # The Service Definition
  systemd.user.services.paperless-sync = {
    Unit = {
      Description = "Sync Paperless-ngx archives from server";
      # Ensure network is up before attempting rsync
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      Type = "oneshot";
      # Using the full path to rsync from the nix store
      #  Ensure no lecture is given for non-interactive sessions
      # security.sudo.extraConfig = ''
      #   Defaults:nixos !lecture
      #   Defaults:nixos !requiretty
      # ''
      ExecStart = let
        syncScript = pkgs.writeShellScript "paperless-sync-task" ''
          set -euo pipefail

          ${pkgs.rsync}/bin/rsync \
            -rv \
            --ignore-existing \
            --delete \
            --rsync-path="sudo rsync" \
            -e "${pkgs.openssh}/bin/ssh -i ${config.home.homeDirectory}/.ssh/id_paperless_sync -o BatchMode=yes -o StrictHostKeyChecking=accept-new" \
            nixos@10.0.0.61:/var/lib/paperless/media/documents/archive/ \
            "${config.home.homeDirectory}/Documents/archive/"
        '';
      in "${syncScript}";   
      # Ensure we don't leak environment vars that might break SSH
      UnsetEnvironment = [ "SSH_AUTH_SOCK" ];
    };
  };

  # The Timer Definition
  systemd.user.timers.paperless-sync = {
    Unit = {
      Description = "Hourly sync of Paperless-ngx archives";
    };
    Timer = {
      # Run every 1 hour
      OnCalendar = "hourly";
      # Persistence ensures it runs immediately if the machine was asleep/off during a scheduled slot
      Persistent = true;
      # Prevent "thundering herd" by spreading the start time by up to 5 minutes
      RandomizedDelaySec = "300s";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

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

