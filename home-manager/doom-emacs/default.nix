{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my-doom-emacs-config;
in {
  options = {
    my-doom-emacs-config = {
      enable = lib.mkEnableOption "enable doom-emacs config";
    };
  };

  config = lib.mkIf cfg.enable {
    services.emacs = {
      enable = true;
    };

    programs.doom-emacs = {
      enable = true;
      doomPrivateDir = ./doom.d;
      # Only init/packages so we only rebuild when those change.
      doomPackageDir = let
        filteredPath = builtins.path {
          path = ./doom.d;
          name = "doom-private-dir-filtered";
          filter = path: type:
            builtins.elem (baseNameOf path) ["init.el" "packages.el"];
        };
      in
        pkgs.linkFarm "doom-packages-dir" [
          {
            name = "init.el";
            path = "${filteredPath}/init.el";
          }
          {
            name = "packages.el";
            path = "${filteredPath}/packages.el";
          }
          {
            name = "config.el";
            path = pkgs.emptyFile;
          }
        ];
    };
  };
}
