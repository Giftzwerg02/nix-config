# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

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
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };


  networking.hostName = "pc";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # NTFS
  boot.supportedFilesystems = [ "ntfs" ];

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

  users.users.benjamin = {
    isNormalUser = true;
    description = "Benjamin Komar";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ ];
  };
  users.defaultUserShell = pkgs.zsh;

  services.xserver = {
    enable = true;
    displayManager = {
      sddm = {
        enable = true;
      };

      setupCommands = ''
        	 ${pkgs.xorg.xrandr}/bin/xrandr --output DP-4 --pos 3000x704 --crtc 2 --mode 1920x1080 --rate 59.93 --output DVI-D-0 --pos 0x0 --crtc 1 --mode 1920x1080 --rate 60.00 --rotate left --output HDMI-0 --pos 1080x704 --crtc 0 --primary --mode 1920x1080 --rate 60.00
        	 '';
    };
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [ i3status i3lock i3blocks ];
    };
    videoDrivers = [ "nvidia" ];
  };

  virtualisation.docker.enable = true;

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
    };
  };

  programs.dconf.enable = true;

  programs.zsh = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Core (Undertale reference!)
    wget
    kitty
    git
    rofi
    libnotify
    dunst
    home-manager
    zsh
    gtk2
    gtk3
    gtk4
    zip
    unzip
    openssl

    # Cli Utils deez nuts 
    pamixer
    killall
    htop
    thefuck
    zoxide
    fzf
    neofetch
    brightnessctl
    xclip
    feh
    mpv
    tldr
    networkmanager_dmenu
    unstable.eza
    bat
    fd
    btop
    ripgrep
    openfortivpn
    imagemagick
    lf
    pistol
    xdragon
    just

    # Gui (eww) Utils
    pavucontrol
    networkmanagerapplet
    vlc
    flameshot
    lxappearance

    # Dev and Work (as if)
    # neovim-nightly
    unstable.neovim
    firefox-devedition
    xournalpp
    bitwarden
    discord
    unstable.obsidian
    zathura
    signal-desktop
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    libsForQt5.kdeconnect-kde
    thunderbird
    jetbrains.idea-ultimate
    remmina
    unstable.onedrive
    umlet

    # Compilers
    clang
    libgccjit
    gcc-unwrapped
    libstdcxx5
    python311
    python311Packages.pip
    unstable.rustc
    unstable.cargo
    unstable.rust-analyzer
    nodejs_20
    unstable.bun
    plantuml
    unstable.typst
    unstable.typstfmt
    unstable.typst-lsp
    texlive.combined.scheme-full
    R

    # LSPs
    nodePackages_latest.pyright
    nodePackages_latest.typescript-language-server
    jdt-language-server

    # Gamer Girl :3
    prismlauncher # mc launcher
    unstable.atlauncher # mc launcher 2
  ];

  environment.etc."ppp/options".text = ''
    ipcp-accept-remote
  '';

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
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

  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # I don't want the onedrive service to be enabled by default
  # Henceforth, I have only added onedrive as a package
  # services.onedrive.enable = true;
  # services.onedrive.package = unstable.onedrive;

  programs.ssh.startAgent = true;
  services.openssh.enable = true;

  hardware.opentabletdriver.enable = true;

  networking.nameservers = [ "1.1.1.1" "8.8.8.8" "192.168.1.1" ];
  networking.defaultGateway = {
    address = "192.168.1.1";
    interface = "enp0s31f6";
  };
  networking.interfaces = {
    enp0s31f6.ipv4.addresses = [{
      address = "192.168.1.184";
      prefixLength = 24;
    }];
  };
  networking.nat = {
    enable = true;
    internalInterfaces = [ "enp0s31f6" ];
    externalInterface = "enp0s31f6";
  };
  services.teamviewer.enable = true;

  system.stateVersion = "23.05"; # Did you read the comment?

}