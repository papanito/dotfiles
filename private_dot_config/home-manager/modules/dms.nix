{ config, pkgs, inputs, ... }:

{
  sops.secrets.google_calendar_url = {
    path = "${config.home.homeDirectory}/.config/calendar_url.secret";
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
        TARGET_DIR="%h/.calendars"
        SECRET_FILE="%h/.config/calendar_url.secret"

        mkdir -p "$TARGET_DIR"

        if [ -f "$SECRET_FILE" ]; then
          # Read line by line, skipping empty lines or comments
          while IFS='|' read -r cal_name cal_url || [ -n "$cal_name" ]; do
            # Strip potential whitespace or carriage returns
            cal_name=$(echo "$cal_name" | xargs)
            cal_url=$(echo "$cal_url" | xargs)

            [[ -z "$cal_name" || "$cal_name" == \#* ]] && continue

            echo "Syncing calendar: $cal_name..."
            ${pkgs.curl}/bin/curl -s -o "$TARGET_DIR/$cal_name.ics" "$cal_url"
          done < "$SECRET_FILE"
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
}
