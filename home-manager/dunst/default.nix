{ lib, config, pkgs, ... }:
let
  cfg = config.my-dunst-config;
in
{
  options = {
    my-dunst-config = {
      enable = lib.mkEnableOption "enable dunst config";
    };
  };

  config = lib.mkIf cfg.enable {
    services.dunst.enable = true;
  };
}
