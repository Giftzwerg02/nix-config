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
    enable = false;
    languagePacks = [ "sk" "en-US" "de" ];
    betterfox = {
      enable = true;
      profiles.default.enableAllSections = true;
    };

    policies = {
      Preferences = let
        ffVersion = config.programs.firefox.package.version;
      in {
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = lib.versionAtLeast ffVersion "137.0.0";
        "media.rdd-ffmpeg.enabled" = true;

        "gfx.x11-egl.force-enabled" = true;
        "widget.dmabuf.force-enabled" = true;
      };
    };
  };


  programs.librewolf = {
    enable = true;
    languagePacks = [ "sk" "en-US" "de" ];
    policies = {
      Preferences = let
        ffVersion = config.programs.librewolf.package.version;
      in {
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = lib.versionAtLeast ffVersion "137.0.0";
        "media.rdd-ffmpeg.enabled" = true;

        "gfx.x11-egl.force-enabled" = true;
        "widget.dmabuf.force-enabled" = true;
      };
    };
  };
}
