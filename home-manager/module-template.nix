{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.cfgname;
in {
  options = {
    cfgname = {
      enable = lib.mkEnableOption "enable cfgname config";
      option =
        lib.mkOption
        {
          type = type;
          description = "";
          default = default;
        };
    };
  };

  config =
    lib.mkIf cfg.enable {
    };
}
