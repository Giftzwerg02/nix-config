{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.niri.nixosModules.niri
    ./hardware-configuration.nix

    ../global.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      inputs.niri.overlays.niri
    ];
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      allow-dirty = false;
    };
  };

  boot = {
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 video_nr=9 card_label=a7III
    '';
    kernelModules = ["kvm-intel" "v4l2loopback" "gcadapter_oc" "hid_nintendo"];
    supportedFilesystems = ["ntfs"];
  };

  users.users.benjamin = {
    isNormalUser = true;
    description = "Benjamin Komar";
    extraGroups = ["networkmanager" "wheel" "adbusers" "gamemode" "libvirtd"];
  };

  # Do not override login-shell
  # https://wiki.nixos.org/wiki/Nushell#Installation
  environment.shells = [ pkgs.nushell ];
  programs.bash.interactiveShellInit = ''
    if ! [ "$TERM" = "dumb" ] && [ -z "$BASH_EXECUTION_STRING" ]; then
      exec nu
    fi
  '';

  virtualisation = {
    docker.enable = false;
    docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };
    libvirtd = {
      enable = true;
      qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
    };
  };

  environment.systemPackages = with pkgs; [
    # Core (Undertale reference!)
    wget
    kitty
    git
    rofi
    fuzzel
    alacritty
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
    zoxide
    fzf
    xclip
    wl-clipboard
    feh
    mpv
    tldr
    eza
    bat
    fd
    ripgrep
    openfortivpn
    imagemagick
    dragon-drop
    toggle-redshift
    ffmpeg
    p7zip
    man-pages
    man-pages-posix

    # Gui (eww) Utils
    pavucontrol
    networkmanagerapplet
    vlc
    ksnip
    obs-studio
    krita
    grayjay
    anki-bin

    # Dev and Work (as if)
    firefox-beta
    rnote
    bitwarden-desktop
    signal-desktop
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    thunderbird
    remmina
    libreoffice-qt6-fresh
    dbeaver-bin
    zoom-us
    blender_with_cuda

    # Compilers
    clang
    libgccjit
    gcc

    # Formatters
    alejandra

    # Gamer Girl :3
    heroic
    prismlauncher

    ## wine stuff
    wineWowPackages.staging
    winetricks
    protontricks
    lutris
    adwaita-icon-theme # needed for lutris
    vesktop
    xwayland-satellite
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

    virt-manager.enable = true;
  };

  services = {
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };

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
    openssh.enable = true;
  };

  programs.niri.enable = true;

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
  };

  system.stateVersion = "23.05"; # Did you read the comment?
}
