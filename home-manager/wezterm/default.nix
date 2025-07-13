{
  ...
}: {
  programs.wezterm = {
    enable = true;
    extraConfig = /* lua */ ''
      local mux = wezterm.mux
      local config = {}

      local function add_to_package_path(dir)
          local path = package.path
          package.path = dir .. '/?.lua;' .. path
      end

      wezterm.on('gui-startup', function(cmd)
        local load_template = os.getenv('MY_WEZTERM_LOAD_LAYOUT')
        if not load_template then
          return
        end

        add_to_package_path(load_template .. '/.layout')
        local template = require('layout')
        template.apply(wezterm, config, cmd)
      end)

      return config
    '';
  };
}
