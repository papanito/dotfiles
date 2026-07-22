{ pkgs, ... }:

{
  # Enable ydotool service and uinput access for Wayland synthetic typing
  programs.ydotool.enable = true;
  hardware.uinput.enable = true;

  # Allow your user account to emit key events without sudo
  users.users.papanto.extraGroups = [
    "input"
    "uinput"
  ];

  # Required tools for Wayland text pasting and typing
  environment.systemPackages = with pkgs; [
    wtype
    ydotool
    wl-clipboard
  ];
}
