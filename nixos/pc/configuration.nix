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

      substituters = [ "https://chaotic-nyx.cachix.org/" ];
      trusted-substituters = [ "https://chaotic-nyx.cachix.org/" ];
      trusted-public-keys = [ "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8=" ];
    };
  };

  boot = {
    extraModulePackages = [
      # Weird-ass stuff for obs-virtual-cam
      config.boot.kernelPackages.v4l2loopback
    ];

    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 video_nr=9 card_label=a7III
    '';

    kernelModules = ["kvm-intel" "v4l2loopback" "gcadapter_oc" "hid_nintendo"];

    # NTFS
    supportedFilesystems = ["ntfs"];
  };

  users.users.benjamin = {
    isNormalUser = true;
    description = "Benjamin Komar";
    extraGroups = ["networkmanager" "wheel" "adbusers" "gamemode"];
    shell = pkgs.nushell;
  };

  virtualisation = {
    docker.enable = true;
    docker.rootless = {
      enable = true;
      setSocketVariable = true;
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
    gtk2
    gtk3
    gtk4
    zip
    unzip
    openssl
    dust

    # Cli Utils deez nuts
    killall
    htop
    pay-respects 
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
    krita

    # Dev and Work (as if)
    firefox-beta
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
    pdftk
    libreoffice
    unstable.dbeaver-bin

    blender_with_cuda
    shaderc
    vulkan-headers
    vulkan-loader
    vulkan-tools

    # Compilers
    clang
    libgccjit
    gcc

    # Formatters
    alejandra

    # Gamer Girl :3
    prismlauncher # mc launcher
    jdk21 # for minecraft obviously
    heroic
    ## wine stuff
    wineWowPackages.staging
    winetricks
    protontricks
    lutris
    adwaita-icon-theme # needed for lutris
    vesktop

    # extras
    # Used for obs virtual cam
    linuxPackages.v4l2loopback
    rar

    anki

    man-pages
    man-pages-posix

    gale
    (writeShellScriptBin "gale-wrapper" ''
      export WEBKIT_DISABLE_DMABUF_RENDERER=1
      exec ${pkgs.gale}/bin/gale "$@"
    '')
  ];

  documentation = {
    enable = true;
    dev.enable = true;
    man.enable = true;
    info.enable = true;
    doc.enable = true;
  };

  programs = {
    gamemode = {
      enable = true;
      settings = {
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      }
      ;
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    gamescope.enable = true;

    nix-ld.enable = true;
    nix-ld.libraries = [
      pkgs.vulkan-loader
    ];
  };

  services = {
    displayManager.sddm.enable = true;
    xserver = {
      displayManager.setupCommands = ''
        ${pkgs.xorg.xrandr}/bin/xrandr --output DVI-D-0 --mode 1920x1080 --pos 1920x0 --rotate left --output HDMI-0 --mode 1920x1080 --pos 0x704 --rotate normal --output DP-0 --off --output DP-1 --primary --mode 1920x1080 --pos 3000x704 --rotate normal --output DP-2 --off --output DP-3 --off --output DP-4 --mode 1920x1080 --pos 4920x704 --rotate normal --output DP-5 --off
      '';
      enable = true;
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [i3status i3lock i3blocks];
      };
      videoDrivers = ["nvidia"];
    };
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    thermald.enable = true;
  };

  networking = {
    hostName = "pc";
    nameservers = ["1.1.1.1" "8.8.8.8" "192.168.1.1"];
    defaultGateway = {
      address = "192.168.1.1";
      interface = "enp0s31f6";
    };
    interfaces = {
      enp0s31f6.ipv4.addresses = [
        {
          address = "192.168.1.184";
          prefixLength = 24;
        }
      ];
    };
    nat = {
      enable = true;
      internalInterfaces = ["enp0s31f6"];
      externalInterface = "enp0s31f6";
    };
  };

  system.stateVersion = "23.05"; # Did you read the comment?
}
