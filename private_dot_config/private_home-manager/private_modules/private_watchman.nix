{ config, pkgs, ... }:

let
  home = config.home.homeDirectory;
  watchman = "${pkgs.watchman}/bin/watchman";
  registerTriggers = pkgs.writeShellScript "watchman-register-triggers" ''
    for _ in {1..50}; do
      ${watchman} --no-spawn watch ${home}/Downloads &&
        ${watchman} --no-spawn watch ${home}/Videos/Movies &&
        ${watchman} --no-spawn watch ${home}/.config/nvim && break
      sleep 0.2
    done
    for file in ${home}/.config/watchman/*.json; do
      ${watchman} --no-spawn -j <"$file" >/dev/null || echo "trigger failed: $file" >&2
    done
  '';
  reapStrayDaemon = pkgs.writeShellScript "watchman-reap-stray-daemon" ''
    pidfile="${home}/.local/state/watchman/papanito-state/pid"
    [ -r "$pidfile" ] || exit 0
    pid=$(cat "$pidfile" 2>/dev/null || true)
    [ -n "$pid" ] || exit 0
    case "$pid" in *[!0-9]*) exit 0 ;; esac
    [ -d "/proc/$pid" ] || exit 0
    grep -q 'watchman.service' "/proc/$pid/cgroup" 2>/dev/null && exit 0
    kill "$pid" 2>/dev/null || true
    for _ in {1..25}; do kill -0 "$pid" 2>/dev/null || exit 0; sleep 0.2; done
    kill -9 "$pid" 2>/dev/null || true
  '';
in
{
  home.packages = [ pkgs.watchman ];

  systemd.user.services.watchman = {
    Unit = {
      Description = "Watchman file watching service";
      After = [ "network.target" ];
      StartLimitIntervalSec = 0;
    };
    Service = {
      ExecStartPre = "${reapStrayDaemon}";
      ExecStart = "${watchman} --foreground";
      ExecStartPost = "${registerTriggers}";
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
