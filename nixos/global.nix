{
  pkgs,
  lib,
  config,
  outputs,
  inputs,
  ...
}: let
  cfg = config.global-setup;
in {
  imports = [];
  options = {
    global-setup = {
      enable = lib.mkEnableOption "enable global config";
    };
  };
  config = {
    global-setup = lib.mkIf cfg.enable {
      nixpkgs = {
        overlays = [
          outputs.overlays.additions
          outputs.overlays.modifications
          outputs.overlays.unstable-packages
          inputs.neovim-nightly-overlay.overlays.default
        ];
        config = {
          allowUnfree = true;
        };
      };

      nix = {
        # This will add each flake input as a registry
        # To make nix3 commands consistent with your flake
        registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

        # This will additionally add your inputs to the system's legacy channels
        # Making legacy nix commands consistent as well, awesome!
        nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

        settings = {
          # Enable flakes and new 'nix' command
          experimental-features = "nix-command flakes";
          # Deduplicate and optimize nix store
          auto-optimise-store = true;

          # Force clean git-directory before rebuilding
          allow-dirty = false;
        };
      };


	  # Use latest Kernel
	  boot.kernelPackages = pkgs.unstable.linuxPackages_latest;

	  # Bootloader
	  boot.loader.systemd-boot.enable = true;
	  boot.loader.efi.canTouchEfiVariables = true;


  # Enable networking
  networking.networkmanager.enable = true;

# Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_AT.UTF-8";

  i18n.extraLocaleSettings = {
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

  # Configure keymap in X11
  services.xserver = {
    layout = "at";
    xkbVariant = "nodeadkeys";
  };

  console.keyMap = "de";

  programs.dconf.enable = true;
  programs.zsh = {
    enable = true;
  };
  users.defaultUserShell = pkgs.zsh;


hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
  };



fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
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
  ];



security.polkit.enable = true;
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };


xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.config.common.default = "gtk";

  # thunar settings
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  location.provider = "manual";
  location.latitude = 48.210033;
  location.longitude = 16.363449;
  services.redshift = {
    enable = true;
    brightness = {
      day = "1";
      night = "0.85";
    };
    temperature = {
      day = 3000;
      night = 2000;
    };
  };

  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
  };

  hardware.opentabletdriver.enable = true;
    };
  };
}
