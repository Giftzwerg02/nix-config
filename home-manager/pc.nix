{
  inputs,
  outputs,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
    inputs.niri.homeModules.niri
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
    wallpapers-map = {
      "DVI-D-1" = ./imgs/left.jpg;
      "DP-1" = ./imgs/middle.jpg;
      "DP-3" = ./imgs/right.jpg;
    };
    wallpapers = [
      ./imgs/zeldafirst.jpg
      ./imgs/left.jpg
      ./imgs/middle.jpg
      ./imgs/right.jpg
    ];
    nixosConfigName = "pc";
    hmConfigName = "benjamin@pc";
  };

  home.username = "benjamin";
  home.homeDirectory = "/home/benjamin";

  programs.home-manager.enable = true;

  programs.nix-index.enable = true;

  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
