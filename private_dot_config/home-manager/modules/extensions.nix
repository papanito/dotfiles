# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "" = {
      idle-activation-enabled = false;
      idle-delay = 0;
      idle-dim = false;
      restore-state = false;
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-type = "nothing";
    };

  };
}
