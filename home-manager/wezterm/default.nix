{
  ...
}: {
  programs.wezterm = {
    enable = true;
    extraConfig = /* lua */ ''
      local mux = wezterm.mux

      wezterm.on('gui-startup', function(cmd)
        local tab, pane, window = mux.spawn_window(cmd or {})
        pane:split { size = 0.3 }
        pane:split { size = 0.5 }
      end)
    '';
  };
}
