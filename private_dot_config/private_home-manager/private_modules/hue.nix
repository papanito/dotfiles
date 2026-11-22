{ pkgs, ... }:
let
  # Rofi front-end for openhue. Runs out of process, so it cannot block the
  # GNOME Shell the way the smart-home extension did.
  hue-menu = pkgs.writeShellApplication {
    name = "hue-menu";
    runtimeInputs = with pkgs; [
      coreutils
      jq
      openhue-cli
      rofi
    ];
    text = ''
      mode="''${1:-rooms}"

      if ! openhue get room >/dev/null 2>&1; then
        rofi -e "openhue cannot reach the Hue bridge. Run 'openhue setup' once."
        exit 1
      fi

      pick() {
        rofi -dmenu -i -p "$1"
      }

      case "$mode" in
        rooms)
          room="$(openhue get room --json | jq -r 'if type == "array" then .[] else . end | .Name' | pick "Hue room")" || exit 0
          [[ -n "$room" ]] || exit 0
          action="$(printf '%s\n' "On" "Off" "Dim 20%" "Dim 50%" "Full" | pick "$room")" || exit 0
          [[ -n "$action" ]] || exit 0
          case "$action" in
            On) openhue set room "$room" --on ;;
            Off) openhue set room "$room" --off ;;
            "Dim 20%") openhue set room "$room" --on --brightness 20 ;;
            "Dim 50%") openhue set room "$room" --on --brightness 50 ;;
            Full) openhue set room "$room" --on --brightness 100 ;;
          esac
          ;;
        scenes)
          scene="$(openhue get scene --json | jq -r 'if type == "array" then .[] else . end | .Name' | sort -u | pick "Hue scene")" || exit 0
          [[ -n "$scene" ]] || exit 0
          openhue set scene "$scene"
          ;;
        *)
          echo "usage: hue-menu [rooms|scenes]" >&2
          exit 2
          ;;
      esac
    '';
  };
in
{
  home.packages = [
    hue-menu
    pkgs.openhue-cli
    pkgs.rofi
  ];

  # Kept here rather than in gnome.nix: that module's config is gated on
  # `gnome.enable`, which is false, so its dconf block never applies.
  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      # custom0-custom7 are existing user bindings; keep their paths or the
      # list replacement below drops them.
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/hue-rooms/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/hue-scenes/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/hue-rooms" = {
      name = "Hue rooms";
      command = "hue-menu rooms";
      binding = "<Super>F9";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/hue-scenes" = {
      name = "Hue scenes";
      command = "hue-menu scenes";
      binding = "<Super>F10";
    };
  };
}
