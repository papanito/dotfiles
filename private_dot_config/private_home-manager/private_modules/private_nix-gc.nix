{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Weekly cleanup of the user nix profile: delete every generation except the
  # newest four, then garbage-collect the store. Writes nothing to chezmoi
  # state; it only prunes the profile's own generations (its GC roots).
  nixUserGc = pkgs.writeShellScript "nix-user-gc" ''
    set -euo pipefail
    # systemd user units run with a minimal PATH and NixOS has no coreutils in
    # /usr/bin, so point PATH at the store tools explicitly.
    PATH="${lib.makeBinPath [
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.gawk
      pkgs.nix
    ]}"

    profile="$HOME/.local/state/nix/profiles/profile"

    generations=$(
      nix-env -p "$profile" --list-generations \
        | grep -E '^[[:space:]]*[0-9]+' \
        | awk '{print $1}'
    )

    # head -n -4 keeps the four newest generations out of the deletion set.
    old=$(echo "$generations" | head -n -4)

    if [[ -z "$old" ]]; then
      echo "nix-user-gc: fewer than five generations, nothing to delete"
      exit 0
    fi
    echo "nix-user-gc: deleting generation(s): $(echo "$old" | tr '\n' ' ')"

    nix-env -p "$profile" --delete-generations $old
    nix-collect-garbage
  '';
in
{
  systemd.user.services.nix-user-gc = {
    Unit = {
      Description = "Delete old generations of the user nix profile and garbage-collect the store";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${nixUserGc}";
    };
  };

  systemd.user.timers.nix-user-gc = {
    Unit = {
      Description = "Weekly user nix profile cleanup";
    };
    Timer = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
