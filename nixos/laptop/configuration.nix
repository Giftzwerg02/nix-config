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

  boot = {
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 video_nr=9 card_label=a7III
    '';
    kernelModules = ["kvm-intel" "v4l2loopback" "gcadapter_oc" "hid_nintendo"];
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

  
  environment.systemPackages = let 
    ani-cli = pkgs.ani-cli.overrideAttrs (oldAttrs: rec {
    version = "5.0";
    src = pkgs.fetchFromGitHub {
    owner = "pystardust";
    repo = "ani-cli";
    rev = "v${version}";
    sha256 = "sha256-rRQESi0Skoyf1jy/dRRK6ooKRPQhkak107kk5ulwZYI=";
    };
    });
  in
  with pkgs; [
    # Core (Undertale reference!)
    wget
    git
    fuzzel
    libnotify
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

    # Gui (eww) Utils
    pavucontrol
    vlc
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

    ares
    archipelago
    lumafly

    yt-dlp
    ani-cli

    go
    templ
    air
    gopls
    typescript
    gcc
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

  programs.nix-ld.enable = true;


  services.openssh.enable = true;

  networking.nameservers = ["1.1.1.1" "8.8.8.8" "192.168.1.1"];

  system.stateVersion = "25.05"; # Did you read the comment?
}
