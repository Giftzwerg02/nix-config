{inputs, ...}: {
  additions = final: _prev:
    import ../pkgs {
      pkgs = final;
    };

  modifications = final: prev: {
    blender_with_cuda = inputs.blender.packages.x86_64-linux.default;
  };

  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
