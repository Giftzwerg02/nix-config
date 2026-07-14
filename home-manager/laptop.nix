{
  inputs,
  outputs,
  config,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
    inputs.niri.homeModules.niri
    inputs.betterfox.homeModules.betterfox
    ./you-definitely-want-this.nix
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
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  setup-this-thing = {
    enable = true;
    wallpapers = [
      ./imgs/background-laptop.jpg
    ];
    wallpapers-map = {
      "eDP-1" = ./imgs/background-laptop.jpg;
    };
    nixosConfigName = "laptop";
    hmConfigName = "benjamin@laptop";
  };

  home.username = "benjamin";
  home.homeDirectory = "/home/benjamin";
  home.pointerCursor.enable = true;

  programs.home-manager.enable = true;
  programs.nix-index.enable = true;

  systemd.user.startServices = "sd-switch";

  # legacy stateVersion stuff
  programs.git.signing.format = null;
  programs.firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}
