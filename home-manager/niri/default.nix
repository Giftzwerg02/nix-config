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
    programs.niri = {
      enable = true;
      settings = {
        outputs = {
          "dvi-d-1" = {
            mode = {
              width = 1920;
              height = 1080;
              refresh = 60.0;
            };
            transform = "90";
            position = {
              x=0; 
              y=0;
            };
          };

          "dp-1" = {
            mode = {
              width = 1920;
              height = 1080;
              refresh = 60.0;
            };
            position = {
              x=0; 
              y=0;
            };
          };

          "dp-3" = {
            mode = {
              width = 1920;
              height = 1080;
              refresh = 60.0;
            };
            position = {
              x=0; 
              y=0;
            };
          };
        };
      };
    };
  };
}
