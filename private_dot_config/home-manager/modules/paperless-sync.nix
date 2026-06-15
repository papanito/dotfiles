{ config, pkgs, ... }:

{
  # The Service Definition
  systemd.user.services.paperless-sync = {
    Unit = {
      Description = "Sync Paperless-ngx archives from server";
      # Ensure network is up before attempting rsync
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
      #OnSuccess = "systemd-googlechat-notifier@%N.service";
      #OnFailure = "systemd-googlechat-notifier@%N.service";
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
}

