{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.my-i3-config;
in {
  options = {
    my-i3-config = {
      enable = lib.mkEnableOption "enable i3 config";
      wallpapers =
        lib.mkOption
        {
          type = with lib.types; listOf (oneOf [str path]);
          description = "provide a list of paths for each wallpaper for each monitor";
          default = ["none"];
        };
    };
  };

  config = let
    bar_name = "bottom";
  in
    lib.mkIf cfg.enable {
      xsession.windowManager.i3 = let
        modifier = "Mod4";
        refresh_i3status = "killall -SIGUSR1 i3status";
        ws1 = "1";
        ws2 = "2";
        ws3 = "3";
        ws4 = "4";
        ws5 = "5";
        ws6 = "6";
        ws7 = "7";
        ws8 = "8";
        ws9 = "9";
        ws10 = "10";
      in {
        enable = true;
      
        extraConfig = ''
          for_window [class="scratchy"] move scratchpad
        '';

        config = {
          modifier = "${modifier}";

          startup = [
            {command = "i3";}
            {command = "nm-applet";}
            {command = "feh " + lib.concatMapStringsSep " " (p: "--bg-fill ${p}") cfg.wallpapers;}
            {command = "--no-startup-id \"${lib.getExe pkgs.wezterm} start --class scratchy\"";}
          ];

          keybindings = {
            "${modifier}+period" = "[class=\"scratchy\"] scratchpad show resize set width 80ppt height 80ppt; move position center";

            "XF86AudioRaiseVolume" = "exec --no-startup-id pamixer --increase 5 && ${refresh_i3status}";
            "XF86AudioLowerVolume" = "exec --no-startup-id pamixer --decrease 5 && ${refresh_i3status}";
            "XF86AudioMute" = "exec --no-startup-id pamixer --togle-mute && ${refresh_i3status}";
            "XF86AudioPlay" = "exec --no-startup-id playerctl play-pause";
            "XF86AudioPause" = "exec --no-startup-id playerctl play-pause";

            "${modifier}+Control+d" = "exec dunstctl action";

            "${modifier}+Return" = "exec ${lib.getExe pkgs.wezterm}";

            "${modifier}+Shift+q" = "kill";

            "${modifier}+p" = "exec \"rofi -show drun -show-icons\"";

            # toggle nightlight (redshift)
            "${modifier}+Shift+a" = "exec \"toggle-redshift\"";

            # screenshot
            "${modifier}+Shift+s" = "exec \"${lib.getExe pkgs.ksnip} -r\"";

            # lock
            "${modifier}+Control+l" = "exec \"i3lock --color 181926\"";

            # change focus
            "${modifier}+j" = "focus left";
            "${modifier}+k" = "focus down";
            "${modifier}+l" = "focus up";
            "${modifier}+odiaeresis" = "focus right";

            # alternatively, you can use the cursor keys:
            "${modifier}+Left" = "focus left";
            "${modifier}+Down" = "focus down";
            "${modifier}+Up" = "focus up";
            "${modifier}+Right" = "focus right";

            # move focused window
            "${modifier}+Shift+j" = "move left";
            "${modifier}+Shift+k" = "move down";
            "${modifier}+Shift+l" = "move up";
            "${modifier}+Shift+h" = "move right";

            # alternatively, you can use the cursor keys:
            "${modifier}+Shift+Left" = "move left";
            "${modifier}+Shift+Down" = "move down";
            "${modifier}+Shift+Up" = "move up";
            "${modifier}+Shift+Right" = "move right";

            # split in horizontal orientation
            "${modifier}+h" = "split h";

            # split in vertical orientation
            "${modifier}+v" = "split v";

            # enter fullscreen mode for the focused container
            "${modifier}+f" = "fullscreen toggle";

            # change container layout (stacked, tabbed, toggle split)
            "${modifier}+s" = "layout stacking";
            "${modifier}+w" = "layout tabbed";
            "${modifier}+e" = "layout toggle split";

            # toggle tiling / floating
            "${modifier}+Shift+space" = "floating toggle";

            # change focus between tiling / floating windows
            "${modifier}+space" = "focus mode_toggle";

            # focus the parent container
            "${modifier}+a" = "focus parent";

            # switch to workspace
            "${modifier}+1" = "workspace number ${ws1}";
            "${modifier}+2" = "workspace number ${ws2}";
            "${modifier}+3" = "workspace number ${ws3}";
            "${modifier}+4" = "workspace number ${ws4}";
            "${modifier}+5" = "workspace number ${ws5}";
            "${modifier}+6" = "workspace number ${ws6}";
            "${modifier}+7" = "workspace number ${ws7}";
            "${modifier}+8" = "workspace number ${ws8}";
            "${modifier}+9" = "workspace number ${ws9}";
            "${modifier}+0" = "workspace number ${ws10}";

            # move container to ws
            "${modifier}+Shift+1" = "move container to workspace number ${ws1}";
            "${modifier}+Shift+2" = "move container to workspace number ${ws2}";
            "${modifier}+Shift+3" = "move container to workspace number ${ws3}";
            "${modifier}+Shift+4" = "move container to workspace number ${ws4}";
            "${modifier}+Shift+5" = "move container to workspace number ${ws5}";
            "${modifier}+Shift+6" = "move container to workspace number ${ws6}";
            "${modifier}+Shift+7" = "move container to workspace number ${ws7}";
            "${modifier}+Shift+8" = "move container to workspace number ${ws8}";
            "${modifier}+Shift+9" = "move container to workspace number ${ws9}";
            "${modifier}+Shift+0" = "move container to workspace number ${ws10}";

            # reload config
            "${modifier}+Shift+c" = "reload";

            # restart i3
            "${modifier}+Shift+r" = "restart";

            "${modifier}+r" = "mode \"resize\"";
          };

          modes = {
            resize = {
              "j" = "resize shrink width 10 px or 10 ppt";
              "k" = "resize grow height 10 px or 10 ppt";
              "l" = "resize shrink height 10 px or 10 ppt";
              "h" = "resize grow width 10 px or 10 ppt";

              # same bindings, but for the arrow keys
              "Left" = "resize shrink width 10 px or 10 ppt";
              "Down" = "resize grow height 10 px or 10 ppt";
              "Up" = "resize shrink height 10 px or 10 ppt";
              "Right" = "resize grow width 10 px or 10 ppt";

              # back to normal: Enter or Escape or $mod+r
              "Return" = "mode \"default\"";
              "Escape" = "mode \"default\"";
              "${modifier}+r" = "mode \"default\"";
            };
          };

          bars = [
            {
              statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-${bar_name}.toml";
            }
          ];
        };
      };

      programs.i3status-rust = {
        enable = true;
        bars = {
          ${bar_name} = {
            theme = "ctp-mocha";
            icons = "awesome6";

            blocks = [
              {
                block = "battery";
              }

              {
                alert = 10.0;
                block = "disk_space";
                info_type = "available";
                interval = 60;
                path = "/";
                warning = 20.0;
              }

              {
                block = "memory";
                format = " $icon $mem_used_percents ";
                format_alt = " $icon $swap_used_percents ";
              }

              {
                block = "cpu";
                interval = 1;
              }

              {
                block = "load";
                format = " $icon $1m ";
                interval = 1;
              }

              {
                block = "sound";
              }

              {
                block = "time";
                format = " $timestamp.datetime(f:'%a %d/%m %R') ";
                interval = 60;
              }
            ];
          };
        };
      };
    };
}
