# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  ...
}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./i3
    ./sway
    ./stylix
    ./git
    ./zoxide
    ./neovim
    ./dunst
    ./mimeApps
    ./wezterm
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

  home.username = "benjamin";
  home.homeDirectory = "/home/benjamin";

  my-i3-config = {
    enable = true;
    wallpapers = [./imgs/background-laptop.jpg];
  };
  my-zoxide-config.enable = true;
  my-neovim-config = {
    enable = true;
    nixosConfigName = "laptop";
    hmConfigName = "benjamin@laptop";
  };

  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
