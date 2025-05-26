{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my-mimeApps-config;
in {
  options = {
    my-mimeApps-config = {
      enable = lib.mkEnableOption "enable mimeApps config";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.enable = true;
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/plain" = ["zathura.desktop"];
        "application/pdf" = ["zathura.desktop"];
        "image/*" = ["feh.desktop"];
        "video/*" = ["mpv.desktop"];
        "inode/directory" = ["thunar.desktop"];

        "default-web-browser" = ["firefox.desktop"];
        "text/html" = ["firefox.desktop"];
        "x-scheme-handler/http" = ["firefox.desktop"];
        "x-scheme-handler/https" = ["firefox.desktop"];
        "x-scheme-handler/about" = ["firefox.desktop"];
        "x-scheme-handler/unknown" = ["firefox.desktop"];
      };
    };
  };
}
