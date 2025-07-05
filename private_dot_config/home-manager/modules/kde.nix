{ config, pkgs, lib, ... }:

let
   cfg = config.kde;
in
{
  options.kde = {
    enable 
      = lib.mkEnableOption "enable kde and install related software";
  };
  config = lib.mkIf cfg.enable {
    programs.plasma = {
      enable = true;

      fonts = {
        general = {
          family = "Noto Sans";
          pointSize = 10;
        };
      };
    };
  };
}