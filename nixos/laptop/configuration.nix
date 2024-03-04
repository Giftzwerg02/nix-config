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
  };

  networking.hostName = "laptop";

  users.users.benjamin = {
    isNormalUser = true;
    description = "Benjamin Komar";
    extraGroups = ["networkmanager" "wheel"];
  };

  services.xserver = {
    enable = true;
    displayManager = {
      sddm = {
        enable = true;
      };
    };
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [i3status i3lock i3blocks];
    };
    videoDrivers = ["intel" "nvidia"];
  };

  virtualisation.docker.enable = true;

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
    # unstable.neovim
    #firefox-devedition
    firefox
    xournalpp
    bitwarden
    unstable.webcord-vencord
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

	chromium
  ];

  networking.nameservers = ["1.1.1.1" "8.8.8.8" "192.168.1.1"];

  system.stateVersion = "23.11"; # Did you read the comment?
}
