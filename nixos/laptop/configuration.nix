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
      substituters = [ "https://attic.xuyh0120.win/lantian" ];
      trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
    };
  };

  environment.etc.hosts.enable = false;
  environment.etc.hosts.mode = "0700";

  networking.hostName = "laptop";

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

  services.desktopManager.plasma6.enable = true;

  services = {
    displayManager.ly.enable = true;
    xserver = {
      enable = true;
      videoDrivers = ["modesetting" "nvidia"];
    };
  };
  programs.niri.enable = true;

  virtualisation = {
    docker.enable = true;
    docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };

    libvirtd = {
      enable = true;
      qemu = {
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    # Core (Undertale reference!)
    wget
    kitty
    git
    fuzzel
    libnotify
    dunst
    home-manager
    gtk2
    gtk3
    gtk4
    zip
    unzip
    dust

    # Cli Utils deez nuts
    pamixer
    killall
    htop
    zoxide
    fzf
    brightnessctl
    xclip
    wl-clipboard
    feh
    mpv
    tealdeer 
    bat
    fd
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
    signal-desktop
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    thunderbird

    # Compilers
    clang
    libgccjit
    gcc-unwrapped

    xwayland-satellite

	  adwaita-icon-theme
    remmina
    anki
    rnote
    dbeaver-bin
  ];

  programs.firefox = {
    enable = true;
    languagePacks = [ "sk" "en-US" "de" ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };


  services.openssh.enable = true;

  networking.nameservers = ["1.1.1.1" "8.8.8.8" "192.168.1.1"];

  system.stateVersion = "25.05"; # Did you read the comment?
}
