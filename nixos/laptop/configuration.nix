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
      permittedInsecurePackages = [
        "openssl-1.1.1w"
      ];
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

      # Force clean git-directory before rebuilding
      allow-dirty = false;
    };
  };

  # Weird-ass stuff for obs-virtual-cam
  boot.extraModulePackages = with pkgs; [
    config.boot.kernelPackages.v4l2loopback
  ];

  boot.extraModprobeConfig = ''
    options v4l2loopback exclusive_caps=1 video_nr=9 card_label=a7III
  '';


  networking.hostName = "laptop";

  # Use latest Kernel
  boot.kernelPackages = pkgs.unstable.linuxPackages_latest;

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
  
  programs.adb.enable = true;
  
  users.users.benjamin = {
    isNormalUser = true;
    description = "Benjamin Komar";
    extraGroups = [ "networkmanager" "wheel" "adbusers" ];
    packages = with pkgs; [ ];
  };
  users.defaultUserShell = pkgs.zsh;

  services.xserver = {
    enable = true;
    displayManager = {
      sddm = {
        enable = true;
      };
    };
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [ i3status i3lock i3blocks ];
    };
    videoDrivers = [ "intel" "nvidia" ];
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
      package = config.boot.kernelPackages.nvidiaPackages.latest;
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
    openssl_1_1

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
    xdragon
    toggle-redshift

    # Gui (eww) Utils
    pavucontrol
    networkmanagerapplet
    vlc
    flameshot
    lxappearance
    obs-studio

    # Dev and Work (as if)
    # neovim-nightly
    unstable.neovim
    #firefox-devedition
    firefox
    xournalpp
    bitwarden
    unstable.webcord-vencord
    unstable.armcord
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
    pandoc
    unstable.mermaid-filter
    pandoc-for-homework 
    pdftk 

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
    heroic
    wineWowPackages.staging
    lutris

    # extras
    # Used for obs virtual cam
    linuxPackages.v4l2loopback
  ];

  environment.etc."ppp/options".text = ''
    ipcp-accept-remote
  '';

  fonts.packages = with pkgs; [
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
  
  system.stateVersion = "23.11"; # Did you read the comment?
}
