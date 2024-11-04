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
  i18n = {
		defaultLocale = "de_AT.UTF-8";
	  extraLocaleSettings = {
		LC_ADDRESS = "de_AT.UTF-8";
		LC_IDENTIFICATION = "de_AT.UTF-8";
		LC_MEASUREMENT = "de_AT.UTF-8";
		LC_MONETARY = "de_AT.UTF-8";
		LC_NAME = "de_AT.UTF-8";
		LC_NUMERIC = "de_AT.UTF-8";
		LC_PAPER = "de_AT.UTF-8";
		LC_TELEPHONE = "de_AT.UTF-8";
		LC_TIME = "de_AT.UTF-8";
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
	zsh.enable = true;  	
	ssh.startAgent = true;
  };

  users.defaultUserShell = pkgs.zsh;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
			#package = config.boot.kernelPackages.nvidiaPackages.latest;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
	  open = false;
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    nerdfonts
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
  ];

  security.polkit.enable = true;
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
	pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
		jack.enable = true;
	};
  };

  hardware = {
	bluetooth.enable = true;
	opentabletdriver.enable = true;
  };
}
