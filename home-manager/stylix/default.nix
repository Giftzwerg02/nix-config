{
  pkgs,
  ...
}: {
  stylix.image = pkgs.fetchurl {
    url = "https://www.pixelstalk.net/wp-content/uploads/2016/05/Epic-Anime-Awesome-Wallpapers.jpg";
    sha256 = "enQo3wqhgf0FEPHj2coOCvo7DuZv+x5rL/WIo4qPI50=";
  };
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    cursor = {
      name = "capitaine-cursors";
      package = pkgs.capitaine-cursors;
      size = 40;
    };
    fonts = {
      sizes = {
        applications = 12;
        desktop = 12;
        popups = 12;
      };

      monospace = {
        package = pkgs.miracode;
        name = "Miracode";
      };
    };

    targets.firefox = {
      profileNames = ["default"];
    };
  };
}
