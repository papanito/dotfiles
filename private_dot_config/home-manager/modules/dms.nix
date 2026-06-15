{ config, pkgs, inputs, ... }:

{
  imports = [
    # Add the DankMaterialShell home module here so Home Manager knows the options exist:
    inputs.dms.homeModules.dank-material-shell
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    defaultSopsFile = ../secrets.yaml; # Adjust this relative path to your actual secrets.yaml
    #age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets.google_calendar_url = {
      path = "${config.home.homeDirectory}/.config/calendar_url.secret";
    };
  };

  programs.dank-material-shell.plugins.dankCalendar = {
    enable = true;
    src = inputs.dms-plugin-calendar;
  };

  systemd.user.services.sync-google-calendar = {
    Unit = {
      Description = "Fetch Multiple Google Workspace Calendars for DMS";
    };
    Service = {
      Type = "oneshot";
      # The script loops through every non-empty line of the decrypted secret
      ExecStart = pkgs.writeShellScript "fetch-gcal" ''
        # Exact path mapping specified by the Radicale 3.x multifilesystem layout engine
        BASE_DIR="/home/papanito/.var/lib/radicale/collections/collection-root/papanito"
        SECRET_FILE="/home/papanito/.config/calendar_url.secret"

        if [ -f "$SECRET_FILE" ]; then
          while IFS='|' read -r cal_name cal_url || [ -n "$cal_name" ]; do
            # Strip trailing/leading white space strings
            cal_name=$(echo "$cal_name" | xargs)
            cal_url=$(echo "$cal_url" | xargs)

            # Skip empty lines or commented hash rows
            [[ -z "$cal_name" || "$cal_name" == \#* ]] && continue

            # Form the strict nested folder endpoint layout
            CAL_DIR="$BASE_DIR/$cal_name"
            mkdir -p "$CAL_DIR"

            # Write the required Radicale validation props header file
            echo '{"tag": "VCALENDAR"}' > "$CAL_DIR/.Radicale.props"

            # Fetch the live stream from Google directly into the extension-less 'data' file
            echo "Syncing calendar metadata row ($cal_name) directly into Radicale..."
            ${pkgs.curl}/bin/curl -s -o "$CAL_DIR/data" "$cal_url"
        else
          echo "Error: SOPS decrypted secret file not found!" >&2
          exit 1
        fi
      '';
    };
  };

  systemd.user.timers.sync-google-calendar = {
    Unit = { Description = "Timer for Google Workspace Calendar Sync"; };
    Timer = {
      OnCalendar = "*:0/15";
      Persistent = true;
    };
    Install = { WantedBy = [ "timers.target" ]; };
  };

  home.packages = [
    pkgs.radicale
  ];
  home.file.".config/radicale/config".text = ''
    [server]
    hosts = 127.0.0.1:5232

    [auth]
    type = htpasswd
    # Point to a credentials file we will manage right next to it
    htpasswd_filename = /home/papanito/.config/radicale/users
    htpasswd_encryption = plain

    [storage]
    filesystem_folder = /home/papanito/.var/lib/radicale/collections
  '';

  home.file.".config/radicale/users".text = ''
    papanito:papanito
  '';

  systemd.user.services.radicale = {
    Unit = {
      Description = "Local Radicale CalDAV Server for DankCalendar";
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = "/home/papanito/.nix-profile/bin/radicale --hosts 127.0.0.1:5232 --storage-filesystem-folder /home/papanito/.var/lib/radicale/collections";
      Restart = "on-failure";
    };
    Install = { WantedBy = [ "default.target" ]; };
  };
}
