{ 
  config,
  lib,
  ...
}: {
  home.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    MOZ_DISABLE_RDD_SANDBOX = "1";
  };
  programs.firefox = {
    enable = true;
    languagePacks = [ "sk" "en-US" "de" ];
    betterfox = {
      enable = true;
      profiles.default.enableAllSections = true;
    };

    policies = {
      Preferences = let
        ffVersion = config.programs.firefox.package.version;
      in {
        "media.ffmpeg.vaapi.enabled" = lib.versionOlder ffVersion "137.0.0";
        "media.hardware-video-decoding.force-enabled" = lib.versionAtLeast ffVersion "137.0.0";
        "media.rdd-ffmpeg.enabled" = lib.versionOlder ffVersion "97.0.0";

        "gfx.x11-egl.force-enabled" = true;
        "widget.dmabuf.force-enabled" = true;
      };
    };
  };
}
