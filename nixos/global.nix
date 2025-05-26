{
  pkgs,
  config,
  ...
}: {
  boot = {
    # Use latest Kernel
    kernelPackages = pkgs.unstable.linuxPackages_latest;

    # Bootloader
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  networking = {
    # Enable networking
    networkmanager.enable = true;
  };

  time = {
    # Set your time zone.
    timeZone = "Europe/Vienna";
  };

  # Select internationalisation properties.
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

  # Configure keymap in X11
  services.xserver = {
    xkb = {
      layout = "at";
      variant = "nodeadkeys";
    };
  };

  console.keyMap = "de";

  programs = {
    dconf.enable = true;
    ssh.startAgent = true;
    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
    };
  };

  users.defaultUserShell = pkgs.nushell;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      open = false;
    };
  };

  fonts.packages = with pkgs;
    [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      ubuntu_font_family
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      font-awesome
      siji
      roboto
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
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    config.common.default = "gtk";
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
          (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/51-disable-suspension.conf" ''
            monitor.alsa.rules = [
              {
                matches = [
                  {
                    # Matches all sources
                    node.name = "~alsa_input.*"
                  },
                  {
                    # Matches all sinks
                    node.name = "~alsa_output.*"
                  }
                ]
                actions = {
                  update-props = {
                    session.suspend-timeout-seconds = 0
                  }
                }
              }
            ]
            # bluetooth devices
            monitor.bluez.rules = [
              {
                matches = [
                  {
                    # Matches all sources
                    node.name = "~bluez_input.*"
                  },
                  {
                    # Matches all sinks
                    node.name = "~bluez_output.*"
                  }
                ]
                actions = {
                  update-props = {
                    session.suspend-timeout-seconds = 0
                  }
                }
              }
            ]
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
