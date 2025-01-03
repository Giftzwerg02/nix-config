{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my-kitty-config;
in {
  options = {
    my-kitty-config = {
      enable = lib.mkEnableOption "enable kitty config";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = "no";
      };
      shellIntegration = {
        enableZshIntegration = true;
      };
    };
  };
}
