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

	gc = {
		automatic = true;
		dates = "weekly";
		options = "--delete-older-than 30d";
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
  };

  services.displayManager = {
      sddm = {
        enable = true;
      };

      setupCommands = ''
        ${pkgs.xorg.xrandr}/bin/xrandr --output DP-4 --pos 3000x704 --crtc 2 --mode 1920x1080 --rate 59.93 --output DVI-D-0 --pos 0x0 --crtc 1 --mode 1920x1080 --rate 60.00 --rotate left --output DP-1 --pos 1080x704 --crtc 0 --primary --mode 1920x1080 --rate 60.00 --rotate normal
      '';
  };

  services.xserver = {
    enable = true;
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
        enable = false;
      };
    };
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
    killall
    htop
    thefuck
    zoxide
    fzf
    xclip
    feh
    mpv
    tldr
    unstable.eza
    bat
    fd
    ripgrep
    openfortivpn
    imagemagick
    xdragon
    toggle-redshift
	ffmpeg
	p7zip

    # Gui (eww) Utils
    pavucontrol
    networkmanagerapplet
    vlc
    flameshot
    obs-studio

    # Dev and Work (as if)
    firefox
	unstable.xournalpp

    bitwarden
    zathura
    signal-desktop
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    thunderbird
    remmina
    pandoc
    pandoc-for-homework
    pdftk
    libreoffice
	unstable.cypress
	unstable.dbeaver-bin

    # Compilers
    clang
    libgccjit
	gcc
    libstdcxx5

    python311
    python311Packages.pip

    unstable.rustc
	rustfmt
    unstable.cargo

    texlive.combined.scheme-full

	# unstable.go
	# unstable.templ
	# unstable.gotools
	# air

	unstable.openapi-generator-cli

    # LSPs
    unstable.rust-analyzer
	# unstable.gopls
	# nodePackages.typescript-language-server
	# nodePackages.typescript

    # Gamer Girl :3
    prismlauncher # mc launcher
	jdk21 # for minecraft obviously
	rconc
    heroic
    wineWowPackages.staging
    lutris
	unstable.vesktop

    # extras
    # Used for obs virtual cam
    linuxPackages.v4l2loopback

	burpsuite
	unstable.ryujinx
	unstable.lime3ds
	rar
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

  system.stateVersion = "23.05"; # Did you read the comment?
}
