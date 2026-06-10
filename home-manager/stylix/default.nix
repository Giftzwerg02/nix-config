{
  pkgs,
  ...
}: {
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    cursor = {
      name = "rose-pine-cursor";
      package = pkgs.rose-pine-cursor;
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
