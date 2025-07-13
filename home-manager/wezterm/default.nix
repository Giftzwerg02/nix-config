{
  ...
}: {
  programs.wezterm = {
    enable = true;
    extraConfig = /* lua */ ''
      local mux = wezterm.mux
      local config = {}

      wezterm.on('gui-startup', function(cmd)
        local load_template = os.getenv('MY_WEZTERM_LOAD_LAYOUT')
        if not load_template then
          return
        end

        local template = require('.layout')
        template.apply(wezterm, config, cmd)
      end)

      return config
    '';
  };
}
