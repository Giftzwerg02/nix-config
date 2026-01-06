{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my-niri-config;
in {
  options = {
    my-niri-config = {
      enable = lib.mkEnableOption "enable niri config";
      wallpapers-map = lib.mkOption 
      {
          description = "a map from monitor-name to wallpaper-path";
          default = null;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.fuzzel.enable = true;
    services.mako.enable = true;
    programs.swaylock.enable = true;
    services.swww.enable = true;
    programs.niri = {
      enable = true;
      # use nixpkgs niri instead of niri-flake niri to make use of cache
      package = pkgs.niri;

      settings = {
        environment."NIXOS_OZONE_WL" = "1";

        # disable window title
        prefer-no-csd = true;

        binds = with config.lib.niri.actions; {
          "Mod+Return".action = spawn "${lib.getExe pkgs.wezterm}";
          "Mod+P".action = spawn "${lib.getExe pkgs.fuzzel}";
          "Super+Alt+L".action = spawn "${lib.getExe pkgs.swaylock}";
          "Mod+O" = {
            repeat = false;
            action = toggle-overview;
          };
          "Mod+Shift+Q" = {
            repeat = false;
            action = close-window;
          };

          "Mod+Left".action = focus-column-left;
          "Mod+Down".action = focus-window-down;
          "Mod+Up".action = focus-window-up;
          "Mod+Right".action = focus-column-right;
          "Mod+H".action = focus-column-left;
          "Mod+J".action = focus-window-down;
          "Mod+K".action = focus-window-up;
          "Mod+L".action = focus-column-right;

          "Mod+Ctrl+Left".action = move-column-left;
          "Mod+Ctrl+Down".action = move-window-down;
          "Mod+Ctrl+Up".action = move-window-up;
          "Mod+Ctrl+Right".action = move-column-right;
          "Mod+Ctrl+H".action = move-column-left;
          "Mod+Ctrl+J".action = move-window-down;
          "Mod+Ctrl+K".action = move-window-up;
          "Mod+Ctrl+L".action = move-column-right;

          "Mod+Shift+Left".action = focus-monitor-left;
          "Mod+Shift+Down".action = focus-monitor-down;
          "Mod+Shift+Up".action = focus-monitor-up;
          "Mod+Shift+Right".action = focus-monitor-right;
          "Mod+Shift+H".action = focus-monitor-left;
          "Mod+Shift+J".action = focus-monitor-down;
          "Mod+Shift+K".action = focus-monitor-up;
          "Mod+Shift+L".action = focus-monitor-right;

          "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
          "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
          "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
          "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;
          "Mod+Shift+Ctrl+H".action = move-column-to-monitor-left;
          "Mod+Shift+Ctrl+J".action = move-column-to-monitor-down;
          "Mod+Shift+Ctrl+K".action = move-column-to-monitor-up;
          "Mod+Shift+Ctrl+L".action = move-column-to-monitor-right;

          "Mod+Page_Down".action = focus-workspace-down;
          "Mod+Page_Up".action = focus-workspace-up;
          "Mod+U".action = focus-workspace-down;
          "Mod+I".action = focus-workspace-up;
          "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
          "Mod+Ctrl+Page_Up".action = move-column-to-workspace-up;
          "Mod+Ctrl+U".action = move-column-to-workspace-down;
          "Mod+Ctrl+I".action = move-column-to-workspace-up;

          "Mod+1".action = focus-workspace 1;
          "Mod+2".action = focus-workspace 2;
          "Mod+3".action = focus-workspace 3;
          "Mod+4".action = focus-workspace 4;
          "Mod+5".action = focus-workspace 5;
          "Mod+6".action = focus-workspace 6;
          "Mod+7".action = focus-workspace 7;
          "Mod+8".action = focus-workspace 8;
          "Mod+9".action = focus-workspace 9;

          "Mod+Comma".action = consume-window-into-column;
          "Mod+Period".action = expel-window-from-column;
          "Mod+R".action = switch-preset-column-width;
          "Mod+Shift+R".action = switch-preset-window-height;
          "Mod+Ctrl+R".action = reset-window-height;
          "Mod+F".action = maximize-column;
          "Mod+Shift+F".action = fullscreen-window;
          "Mod+Ctrl+F".action = expand-column-to-available-width;

          "Mod+Minus".action = set-column-width "-10%";
          "Mod+Plus".action = set-column-width "+10%";

          "Mod+V".action = toggle-window-floating;

          "Mod+Shift+S".action.screenshot = [];

          "XF86AudioRaiseVolume".action = spawn ["${lib.getBin pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05+"];
          "XF86AudioLowerVolume".action = spawn ["${lib.getBin pkgs.wireplumber}/bin/wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05-"];
          "XF86AudioMute".action = spawn ["${lib.getBin pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
          "XF86AudioPlay".action = spawn ["${lib.getExe pkgs.playerctl}" "play-pause"];
          "XF86AudioPause".action = spawn ["${lib.getExe pkgs.playerctl}" "play-pause"];        
        };

        outputs = {
          "dvi-d-1" = {
            mode = {
              width = 1920;
              height = 1080;
              refresh = 60.0;
            };
            transform.rotation = 90;
            position = {
              x=0; 
              y=-715;
            };
          };

          "dp-1" = {
            mode = {
              width = 1920;
              height = 1080;
              refresh = 60.0;
            };
            position = {
              x=0; 
              y=0;
            };
          };

          "dp-3" = {
            mode = {
              width = 1920;
              height = 1080;
              refresh = 60.0;
            };
            position = {
              x=0; 
              y=0;
            };
          };
        };

        input = {
          focus-follows-mouse.enable = false;
          workspace-auto-back-and-forth = true;
        };

        spawn-at-startup = let 
          spawn-wallpapers = lib.mapAttrsToList (monitor: image: {
            argv = [ (lib.getExe pkgs.swww) "${image}" "-o" "${monitor}" ];
          }) cfg.wallpapers-map;
        in [ 
            { argv = [ (lib.getExe pkgs.mako) ]; }
        ] ++ spawn-wallpapers;
      };
    };
  };
}
