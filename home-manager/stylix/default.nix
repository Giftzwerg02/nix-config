{ lib, config, pkgs, ... }:
let
  cfg = config.my-stylix-config;
in
{
  options = {
    my-stylix-config = {
      enable = lib.mkEnableOption "enable stylix config";
    };
  };

  config = lib.mkIf cfg.enable
    {

      stylix.image = pkgs.fetchurl {
        url = "https://www.pixelstalk.net/wp-content/uploads/2016/05/Epic-Anime-Awesome-Wallpapers.jpg";
        sha256 = "enQo3wqhgf0FEPHj2coOCvo7DuZv+x5rL/WIo4qPI50=";
      };
      stylix = {
        polarity = "dark";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/onedark.yaml";
        # base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
        cursor = {
          name = "capitaine-cursors";
          package = pkgs.capitaine-cursors;
          size = 40;
        };
        fonts = {
          sizes = {
            applications = 12;
            desktop = 12;
            popups = 8;
          };

        };
      };
    };
}
