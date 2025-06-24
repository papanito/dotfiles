{ lib, config, pkgs, ... }:
{
  imports = [
    ./gnome.nix
    ./kde.nix
  ];
}