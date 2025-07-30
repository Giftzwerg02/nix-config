# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./you-definitely-want-this.nix
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
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  setup-this-thing = {
    enable = true;
    wallpapers = [
      ./imgs/zeldafirst.jpg
      ./imgs/left.jpg
      ./imgs/middle.jpg
      ./imgs/right.jpg
    ];
    nixosConfigName = "pc";
    hmConfigName = "benjamin@pc";
  };

  services.arrpc.enable = true;

  home.username = "benjamin";
  home.homeDirectory = "/home/benjamin";

  programs.home-manager.enable = true;
  programs.zathura.enable = true;

  programs.nix-index.enable = true;
  programs.command-not-found.enable = false;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.unstable.xdg-desktop-portal-termfilechooser
    ];

    config.common = {
      "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
    };
  };

  xdg.configFile."xdg-desktop-portal-termfilechooser/config" = {
    force = true;
    text = ''
      [filechooser]
      cmd=${pkgs.unstable.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
    '';
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.sessionVariables = {
    LD_LIBRARY_PATH = ''''${LD_LIBRARY_PATH}:${pkgs.vulkan-loader}/lib'';
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
