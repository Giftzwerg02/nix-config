{
  ...
}: {
  programs.wezterm = {
    enable = true;
    extraConfig = /* lua */ ''
      local mux = wezterm.mux
      local config = {}

      wezterm.on('gui-startup', function(cmd)
        if cmd.args ~= 'cwd-template' then 
          return 
        end

        local cwd = cmd.cwd
        local template = require(cwd .. '.layout/layout.lua')
        template.apply(wezterm, config, cmd)
      end)

      return config
    '';
  };
}
