{
  pkgs,
  config,
  ...
}: {
  boot = {
    kernelPackages = pkgs.unstable.linuxPackages_latest;

    # Bootloader
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Vienna";

  i18n = let
    # locale = "de_AT.UTF-8";
    locale = "sk_SK.UTF-8";
  in {
    supportedLocales = [
      "all"
      locale
      "en_US.UTF-8"
      "de_AT.UTF-8"
    ];
    defaultLocale = locale;
    extraLocaleSettings = {
      LC_ADDRESS = locale;
      LC_IDENTIFICATION = locale;
      LC_MEASUREMENT = locale;
      LC_MONETARY = locale;
      LC_NAME = locale;
      LC_NUMERIC = locale;
      LC_PAPER = locale;
      LC_TELEPHONE = locale;
      LC_TIME = locale;
    };
  };

  services.xserver.xkb = {
    layout = "at";
    variant = "nodeadkeys";
  };

  console.keyMap = "de";

  programs = {
    dconf.enable = true;
    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
    };
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      open = false;
    };
  };

  fonts.packages = with pkgs;
    [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      ubuntu-classic
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      font-awesome
      siji
      roboto
      miracode
    ]
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk 
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal
    ];
    config = {
      common = {
        default = "gtk gnome";
        "org.freedesktop.impl.portal.ScreenCast" = "gnome";
        "org.freedesktop.impl.portal.Screenshot" = "gnome";
        "org.freedesktop.impl.portal.RemoteDesktop" = "gnome";
      };
      niri.default = [
        "gtk"
        "gnome"
        "wlr"
      ];
    };
    wlr.enable = true;
  };

  location = {
    provider = "manual";
    latitude = 48.210033;
    longitude = 16.363449;
  };

  services = {
    # thunar settings
    gvfs.enable = true;
    tumbler.enable = true;
    blueman.enable = true;
    redshift = {
      enable = true;
      brightness = {
        day = "1";
        night = "1";
      };
      temperature = {
        day = 3000;
        night = 2000;
      };
    };
    playerctld.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber = {
        # this prevents my bluetooth headphones from using mic which fucks the audio-quality
        configPackages = [
          (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/11-bluetooth-policy.conf" ''
            wireplumber.settings = { bluetooth.autoswitch-to-headset-profile = false }
          '')
        ];
      };
    };
  };

  hardware = {
    bluetooth = {
      enable = true;
      hsphfpd = {
        enable = false;
      };
    };
    opentabletdriver = {
      enable = true;
    };
  };
}
