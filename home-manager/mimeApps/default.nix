{
  ...
}: {
  xdg.enable = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = ["firefox.desktop"];
      "application/pdf" = ["firefox.desktop"];
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
}
