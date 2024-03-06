# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
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

    ../global.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      # inputs.neovim-nightly-overlay.overlays.default
    ];
    config = {
      allowUnfree = true;
	  permittedInsecurePackages = [
        "electron-25.9.0"
      ];
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

  boot.extraModulePackages = [
    # Weird-ass stuff for obs-virtual-cam
    config.boot.kernelPackages.v4l2loopback
  ];

  boot.extraModprobeConfig = ''
    options v4l2loopback exclusive_caps=1 video_nr=9 card_label=a7III
  '';

  boot.kernelModules = ["kvm-intel" "v4l2loopback" "gcadapter_oc"];

  networking.hostName = "pc";

  # NTFS
  boot.supportedFilesystems = ["ntfs"];

  users.users.benjamin = {
    isNormalUser = true;
    description = "Benjamin Komar";
    extraGroups = ["networkmanager" "wheel" "adbusers" "user-with-access-to-virtualbox"];
    packages = [];
  };

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
      extraPackages = with pkgs; [i3status i3lock i3blocks];
    };
    videoDrivers = ["nvidia"];
  };

  virtualisation = {
    docker.enable = true;
	docker.rootless = {
		enable = true;
		setSocketVariable = true;
	};
    virtualbox = {
      host = {
        enable = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
  	xautoclick
  unstable.discord-screenaudio
  	unstable.discord
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
    xdragon
    toggle-redshift

    # Gui (eww) Utils
    pavucontrol
    networkmanagerapplet
    vlc
    flameshot
    lxappearance
    obs-studio
	unstable.spotube

    # Dev and Work (as if)
    # neovim-nightly
    # unstable.neovim
    #firefox-devedition
    firefox
    xournalpp
	gnome.adwaita-icon-theme
    bitwarden
    unstable.webcord-vencord
    unstable.armcord
    # unstable.obsidian
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
    libreoffice

    # Compilers
    clang
    libgccjit
    gcc-unwrapped
    libstdcxx5
    python311
    python311Packages.pip
    unstable.rustc
	rustfmt
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
	unstable.jdt-language-server
	nodePackages."@angular/language-server"

    # Gamer Girl :3
    prismlauncher # mc launcher
    unstable.atlauncher # mc launcher 2
    heroic
    wineWowPackages.staging
    lutris
	unstable.r2modman

    # extras
    # Used for obs virtual cam
    linuxPackages.v4l2loopback

	gobject-introspection
	pango
	libjpeg
	openjpeg
	libffi
  ];



  environment.etc."ppp/options".text = ''
    ipcp-accept-remote
  '';

  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  networking.nameservers = ["1.1.1.1" "8.8.8.8" "192.168.1.1"];
  networking.defaultGateway = {
    address = "192.168.1.1";
    interface = "enp0s31f6";
  };
  networking.interfaces = {
    enp0s31f6.ipv4.addresses = [
      {
        address = "192.168.1.184";
        prefixLength = 24;
      }
    ];
  };
  networking.nat = {
    enable = true;
    internalInterfaces = ["enp0s31f6"];
    externalInterface = "enp0s31f6";
  };

  services.teamviewer.enable = true;

  system.stateVersion = "23.05"; # Did you read the comment?
}
