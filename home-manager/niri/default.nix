{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my-niri-config;
in {
  options = {
    my-niri-config = {
      enable = lib.mkEnableOption "enable niri config";
      wallpapers =
        lib.mkOption
        {
          type = with lib.types; listOf (oneOf [str path]);
          description = "provide a list of paths for each wallpaper for each monitor";
          default = ["none"];
        };
    };
  };

  config = lib.mkIf cfg.enable {
     
  };
}
