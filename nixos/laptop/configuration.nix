{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../global.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
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

  networking.hostName = "laptop";

  users.users.benjamin = {
    isNormalUser = true;
    description = "Benjamin Komar";
    extraGroups = ["networkmanager" "wheel"];
  };

  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  services.xserver = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [i3status i3lock i3blocks];
    };

    videoDrivers = ["modesetting" "nvidia"];
  };

  services.displayManager.sddm.enable = true;
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
    gtk2
    gtk3
    gtk4
    zip
    unzip

    # Cli Utils deez nuts
    pamixer
    killall
    htop
    pay-respects
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
    dragon-drop
    toggle-redshift

    # Gui (eww) Utils
    pavucontrol
    networkmanagerapplet
    vlc
    ksnip
    obs-studio

    # Dev and Work (as if)
    bitwarden-desktop
    zathura
    signal-desktop
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    thunderbird

    # Compilers
    clang
    libgccjit
    gcc-unwrapped

	  adwaita-icon-theme
    remmina
    anki
    rnote
  ];

  programs.firefox = {
    enable = true;
    languagePacks = [ "sk" "en-US" "de" ];
  };

  services.openssh.enable = true;

  networking.nameservers = ["1.1.1.1" "8.8.8.8" "192.168.1.1"];

  system.stateVersion = "25.05"; # Did you read the comment?
}
