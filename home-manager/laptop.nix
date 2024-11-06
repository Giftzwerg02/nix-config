# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./i3
	./sway
    ./stylix
    ./git
    ./kitty
    ./carapace
    ./zsh
    ./zoxide
    ./neovim
    ./dunst
    ./mimeApps
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

  # setup-this-thing = {
  #   wallpapers = [./imgs/background-laptop.jpg];
  # };


	my-stylix-config.enable = true;
	my-git-config.enable = true;
	my-kitty-config.enable = true;
	my-i3-config = { # seems broken lmao
		enable = false;
        wallpapers = [./imgs/background-laptop.jpg];
	};
	my-sway-config = {
		enable = true;
        wallpapers = [./imgs/background-laptop.jpg];
	};
	my-carapace-config.enable = true;
	my-zsh-config.enable = true;
	my-zoxide-config.enable = true;
	my-neovim-config.enable = true;
	my-dunst-config.enable = true;
	my-mimeApps-config.enable = true;

  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
