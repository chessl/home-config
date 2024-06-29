{ pkgs, lib, config, ... }:

let

  cfg = config.my.modules.wm;

in
{
  options = with lib; {
    my.modules.wm = {
      enable = mkEnableOption ''
        Whether to enable wm module
      '';
    };
  };

  config = with lib;
    mkIf cfg.enable {
      services.yabai = {
        enable = true;
        # enableScriptingAddition = true;
        config = {
          # layout
          layout = "bsp";
          auto_balance = "off";
          split_ratio = "0.50";
          window_placement = "second_child";
          window_topmost = "on";

          # Gaps
          window_gap = 15;
          # https://github.com/koekeishiya/yabai/issues/793
          top_padding = 15;
          bottom_padding = 15;
          left_padding = 15;
          right_padding = 15;

          # shadows and borders
          window_shadow = "off";
          window_border = "off";
          window_border_width = 2;
          window_opacity = "on";
          window_opacity_duration = "0.1";
          active_window_opacity = "1.0";
          normal_window_opacity = "0.9";

          active_window_border_color = "0xE0808080";
          normal_window_border_color = "0x00010101";
          insert_feedback_color = "0xE02d74da";

          # mouse
          mouse_modifier = "fn";
          mouse_action1 = "move";
          mouse_action2 = "resize";
          mouse_drop_action = "swap";
          mouse_follows_focus = "off";
        };
        extraConfig = ''
          # rules
          yabai -m rule --add label="Finder" app="^Finder$" title="(Co(py|nnect)|Move|Info|Pref)" manage=off
          yabai -m rule --add label="System Preferences" app="^System Preferences$" manage=off
          yabai -m rule --add label="System Settings" app="^System Settings$" manage=off
          yabai -m rule --add label="App Store" app="^App Store$" manage=off
          yabai -m rule --add label="Activity Monitor" app="^Activity Monitor$" manage=off
          yabai -m rule --add label="Calculator" app="^Calculator$" manage=off
          yabai -m rule --add label="Dictionary" app="^Dictionary$" manage=off
          yabai -m rule --add label="Software Update" title="Software Update" manage=off
          yabai -m rule --add label="System Information" app="System Information" title="About This Mac" manage=off
          # yabai -m rule --add label="Safari" app="^Safari$" title="^(General|(Tab|Password|Website|Extension)s|AutoFill|Se(arch|curity)|Privacy|Advance)$" manage=off
          yabai -m rule --add label="Surge" app="^Surge$" manage=off
          yabai -m rule --add label="1Password" app="^1Password.*" manage=off
          yabai -m rule --add label="Raycast" app="^Raycast.*" manage=off
          yabai -m rule --add label="WeChat" app="^WeChat.*" manage=off
          yabai -m rule --add label="Feishu" app="^Feishu.*" manage=off
          yabai -m rule --add label="Lark" app="^Lark.*" manage=off
          yabai -m rule --add label="OmniFocus" app="^OmniFocus.*" manage=off
          yabai -m rule --add label="SentinelOne" app="^Sentinel.*" manage=off
          yabai -m rule --add label="Keka" app="^Keka.*" manage=off
          yabai -m rule --add label="Music" app="^Music.*" manage=off
          yabai -m rule --add label="IINA" app="^IINA.*" manage=off
          yabai -m rule --add label="FeiLian" app="^FeiLian.*" manage=off
        '';
      };

      services.skhd = {
        enable = true;
        package = pkgs.skhd;
        skhdConfig = ''
          # open terminal
          alt - return : open -na kitty

          # focus window
          lalt - h : yabai -m window --focus west
          lalt - j : yabai -m window --focus south
          lalt - k : yabai -m window --focus north
          lalt - l : yabai -m window --focus east

          # swap managed window
          shift + lalt - h : yabai -m window --swap west
          shift + lalt - l : yabai -m window --swap east
          shift + lalt - j : yabai -m window --swap south
          shift + lalt - k : yabai -m window --swap north

          # focus spaces
          alt - x : yabai -m space --focus recent
          alt - m : yabai -m space --focus last
          alt - p : yabai -m space --focus prev
          alt - n : yabai -m space --focus next
          alt - 1 : yabai -m space --focus 1
          alt - 2 : yabai -m space --focus 2
          alt - 3 : yabai -m space --focus 3
          alt - 4 : yabai -m space --focus 4
          alt - 5 : yabai -m space --focus 5
          alt - 6 : yabai -m space --focus 6
          alt - 7 : yabai -m space --focus 7
          alt - 8 : yabai -m space --focus 8

          # focus on next/prev space
          # alt + ctrl - q : yabai -m space --focus prev
          # alt + ctrl - e : yabai -m space --focus next

          # Move focus container to workspace
          shift + alt - x : yabai -m window --space recent; yabai -m space --focus recent
          shift + alt - m : yabai -m window --space last; yabai -m space --focus last
          shift + alt - p : yabai -m window --space prev; yabai -m space --focus prev
          shift + alt - n : yabai -m window --space next; yabai -m space --focus next
          shift + alt - 1 : yabai -m window --space 1; yabai -m space --focus 1
          shift + alt - 2 : yabai -m window --space 2; yabai -m space --focus 2
          shift + alt - 3 : yabai -m window --space 3; yabai -m space --focus 3
          shift + alt - 4 : yabai -m window --space 4; yabai -m space --focus 4
          shift + alt - 5 : yabai -m window --space 5; yabai -m space --focus 5
          shift + alt - 6 : yabai -m window --space 6; yabai -m space --focus 6
          shift + alt - 7 : yabai -m window --space 7; yabai -m space --focus 7
          shift + alt - 8 : yabai -m window --space 8; yabai -m space --focus 8

          # Resize windows
          lctrl + alt - h : yabai -m window --resize left:-50:0; \
                            yabai -m window --resize right:-50:0
          lctrl + alt - j : yabai -m window --resize bottom:0:50; \
                            yabai -m window --resize top:0:50
          lctrl + alt - k : yabai -m window --resize top:0:-50; \
                            yabai -m window --resize bottom:0:-50
          lctrl + alt - l : yabai -m window --resize right:50:0; \
                            yabai -m window --resize left:50:0

          # float / unfloat window and center on screen
          lalt - t : yabai -m window --toggle float;\
                    yabai -m window --grid 4:4:1:1:2:2

          # toggle window zoom
          # lalt - z : yabai -m window --toggle zoom-parent

          # Equalize size of windows
          lctrl + alt - e : yabai -m space --balance

          # Enable / Disable gaps in current workspace
          lctrl + alt - g : yabai -m space --toggle padding; yabai -m space --toggle gap

          # Rotate windows clockwise and anticlockwise
          alt - r         : yabai -m space --rotate 270
          shift + alt - r : yabai -m space --rotate 90

          # Rotate on X and Y Axis
          shift + alt - x : yabai -m space --mirror x-axis
          shift + alt - y : yabai -m space --mirror y-axis

          # Set insertion point for focused container
          shift + lctrl + alt - h : yabai -m window --insert west
          shift + lctrl + alt - j : yabai -m window --insert south
          shift + lctrl + alt - k : yabai -m window --insert north
          shift + lctrl + alt - l : yabai -m window --insert east

          # Float / Unfloat window
          shift + alt - space : \
              yabai -m window --toggle float; \
              yabai -m window --toggle border

          # Make window native fullscreen
          lalt - z         : yabai -m window --toggle zoom-fullscreen
          shift + alt - f : yabai -m window --toggle native-fullscreen

          # Split switch
          lalt - s : yabai -m window --toggle split
      '';
      };
    };
}
