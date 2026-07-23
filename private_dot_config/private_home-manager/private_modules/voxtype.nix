{ pkgs, ... }:

{
  # Install CLI tools for Wayland typing and clipboard interaction
  home.packages = with pkgs; [
    wtype
    ydotool
    wl-clipboard
    voxtype
  ];

  # 2. Declaratively manage the Voxtype config file (~/.config/voxtype/config.toml)
  xdg.configFile."voxtype/config.toml".text = ''
    # Default transcription engine (Options: "cohere", "parakeet", "whisper", "sensevoice", etc.)
    engine = "whisper"

    [whisper]
    model = "base.en" # Options: tiny.en, base.en, small.en, medium.en

    [audio]
    # Set explicitly to your physical analog microphone
    device = "default"
    sample_rate = 16000
    max_duration_secs = 30

    [audio.feedback]
    enabled = true

    [output]
    mode = "type"
    fallback_to_clipboard = true  # Use clipboard if typing drivers fail

    [osd]
    enabled = false

    [output.notification]
    on_recording_start = true   # Notify when PTT activates
    on_recording_stop = true    # Notify when transcribing
    on_transcription = true     # Show transcribed text

    # Let GNOME handle the keybindings
    [hotkey]
    enabled = false

    [text]
    spoken_punctuation = true

    [text.replacements]
    "vox type" = "voxtype"
    "nix os" = "NixOS"
  '';

  # 3. Create a background user daemon for Voxtype
  systemd.user.services.voxtype = {
    Unit = {
      Description = "Voxtype Voice-to-Text Daemon";
      Documentation = "https://voxtype.io";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.voxtype}/bin/voxtype";
      Restart = "always";
      RestartSec = "3s";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
