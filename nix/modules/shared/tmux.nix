{ pkgs, lib, config, ... }:

let

  cfg = config.my.modules.tmux;

in
{
  options = with lib; {
    my.modules.tmux = {
      enable = mkEnableOption ''
        Whether to enable tmux module
      '';
    };
  };

  config = with lib;
    mkIf cfg.enable {
      my.user = { packages = with pkgs; [ reattach-to-user-namespace ]; };

      programs = {
        tmux = {
          enable = true;
        };
      };

      home-manager.users."${config.my.username}" = {
        programs = {
          tmux = {
            enable = true;
            keyMode = "vi";
            prefix = "C-a";
            # shell = "${pkgs.bash}/bin/bash";
            # terminal = "screen-256color";
            baseIndex = 1;
            escapeTime = 0;
            historyLimit = 999999;

            sensibleOnTop = true;

            plugins = with pkgs; [
              # tmuxPlugins.nord
              # tmuxPlugins.urlview
              # tmuxPlugins.battery
              # tmuxPlugins.cpu
            ];

            extraConfig = ''
              ###################################################################
              # General
              ###################################################################

              # set-option -g default-command env -i USER="$USER" LOGNAME="$LOGNAME" $SHELL

              # Workaround to allow acessing OSX pasteboard
              set-option -g default-command "reattach-to-user-namespace -l $SHELL"
              if-shell "uname | grep -q Darwin" {
                bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel 'reattach-to-user-namespace pbcopy'
                bind-key -T copy-mode-vi Enter send -X copy-pipe-and-cancel 'reattach-to-user-namespace pbcopy'
              } {
                bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
                bind-key -T copy-mode-vi Enter send -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
              }

              # Appropriate terminal colors
              # set -g default-terminal "xterm-256color"
              # Enables truecolor support
              set -as terminal-features ",xterm-256color:RGB"
              set -as terminal-overrides ",xterm-256color:RGB"

              # Start tabs at index 1
              set -g base-index 1

              # Make pane numbering consistent with windows
              setw -g pane-base-index 1

              # Renumber windows when a window is closed
              set -g renumber-windows on

              # Automatically set window title
              set-window-option -g automatic-rename on
              set-option -g set-titles on

              # Faster command sequences
              set -s escape-time 10

              # Increase repeat timeout
              set -sg repeat-time 600

              # Redraw status line every 10 seconds
              set -g status-interval 10

              # Slightly longer pane indicators display time
              set -g display-panes-time 800

              # Slightly longer status messages display time
              set -g display-time 1000

              # Activity
              set -g monitor-activity on
              set -g visual-activity off

              # New window retains current path, possible values are:
              tmux_conf_new_window_retain_current_path=false

              # New pane retains current path, possible values are:
              tmux_conf_new_pane_retain_current_path=true

              # prompt for session name when creating a new session
              tmux_conf_new_session_prompt=false

              ###################################################################
              # Key-bindings
              ###################################################################

              # Free the original `Ctrl-b` prefix keybinding.
              unbind C-b

              # set prefix key to ctrl-a
              set -g prefix C-a

              # set -g default-terminal screen-256color
              set -g status-keys vi
              set -g history-limit 10000

              # mouse? real hackers don't use a mouse
              set-option -g mouse off

              # vi keys for switching panes
              bind-key h select-pane -L
              bind-key j select-pane -D
              bind-key k select-pane -U
              bind-key l select-pane -R

              # Splitting panes.
              bind | split-window -h
              bind - split-window -v

              # # Vi copypaste
              setw -g mode-keys vi
              unbind p
              bind p paste-buffer
              bind-key -T copy-mode-vi v send-keys -X begin-selection
              # bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

              # shift-movement keys will resize panes
              bind J resize-pane -D 5
              bind K resize-pane -U 5
              bind H resize-pane -L 5
              bind L resize-pane -R 5

              bind M-j resize-pane -D
              bind M-k resize-pane -U
              bind M-h resize-pane -L
              bind M-l resize-pane -R

              # No delay for escape key press
              set -sg escape-time 0

              # Reload the file with Prefix r.
              bind r source-file ~/.tmux.conf \; display "Reloaded!"

              # toggle mouse
              bind m run "cut -c3- ~/.tmux.conf | sh -s _toggle_mouse"

              # edit configuration
              bind e new-window -n "~/.tmux.conf" "sh -c '\${EDITOR:-nvim} ~/.tmux.conf && tmux source ~/.tmux.conf && tmux display \"~/.tmux.conf sourced\"'"

              # disappered default keys
              # https://gist.github.com/zchee/37b4795f735ed78600c9
              # bind-key , command-prompt -I #W "rename-window '%%'"
              # bind-key . command-prompt "move-window -t '%%'"

              ###################################################################
              # Visual configs
              ###################################################################

              # # window style
              # tmux_conf_theme_window_fg='default'
              # tmux_conf_theme_window_bg='default'

              # # highlight focused pane (tmux >= 2.1), possible values are:
              # #   - true
              # #   - false (default)
              # tmux_conf_theme_highlight_focused_pane=false

              # # focused pane colours:
              # tmux_conf_theme_focused_pane_fg='default'
              # tmux_conf_theme_focused_pane_bg='#88c0d0'               # light blue

              # # pane border style, possible values are:
              # #   - thin (default)
              # #   - fat
              # tmux_conf_theme_pane_border_style=thin

              # # pane borders colours:
              # tmux_conf_theme_pane_border='#444444'                   # gray
              # tmux_conf_theme_pane_active_border='#E5E9F0'            # light blue

              # # pane indicator colours
              # tmux_conf_theme_pane_indicator='#E5E9F0'                # light blue
              # tmux_conf_theme_pane_active_indicator='#E5E9F0'         # light blue

              # # status line style
              # tmux_conf_theme_message_fg='#000000'                    # black
              # tmux_conf_theme_message_bg='#ffff00'                    # yellow
              # tmux_conf_theme_message_attr='bold'

              # # status line command style (<prefix> : Escape)
              # tmux_conf_theme_message_command_fg='#ffff00'            # yellow
              # tmux_conf_theme_message_command_bg='#000000'            # black
              # tmux_conf_theme_message_command_attr='bold'

              # # window modes style
              # tmux_conf_theme_mode_fg='#000000'                       # black
              # tmux_conf_theme_mode_bg='#ffff00'                       # yellow
              # tmux_conf_theme_mode_attr='bold'

              # # status line style
              # tmux_conf_theme_status_fg='#8a8a8a'                     # light gray
              # tmux_conf_theme_status_bg='#080808'                     # dark gray
              # tmux_conf_theme_status_attr='none'

              # # terminal title
              # #   - built-in variables are:
              # #     - #{circled_window_index}
              # #     - #{circled_session_name}
              # #     - #{hostname}
              # #     - #{hostname_ssh}
              # #     - #{username}
              # #     - #{username_ssh}
              # tmux_conf_theme_terminal_title='#h ❐ #S ● #I #W'

              # # window status style
              # #   - built-in variables are:
              # #     - #{circled_window_index}
              # #     - #{circled_session_name}
              # #     - #{hostname}
              # #     - #{hostname_ssh}
              # #     - #{username}
              # #     - #{username_ssh}
              # tmux_conf_theme_window_status_fg='#8a8a8a'              # light gray
              # tmux_conf_theme_window_status_bg='#080808'              # dark gray
              # tmux_conf_theme_window_status_attr='none'
              # tmux_conf_theme_window_status_format='#I #W'
              # #tmux_conf_theme_window_status_format='#{circled_window_index} #W'
              # #tmux_conf_theme_window_status_format='#I #W#{?window_bell_flag,🔔,}#{?window_zoomed_flag,🔍,}'

              # # window current status style
              # #   - built-in variables are:
              # #     - #{circled_window_index}
              # #     - #{circled_session_name}
              # #     - #{hostname}
              # #     - #{hostname_ssh}
              # #     - #{username}
              # #     - #{username_ssh}
              # tmux_conf_theme_window_status_current_fg='#000000'      # black
              # tmux_conf_theme_window_status_current_bg='#E5E9F0'      # light blue
              # tmux_conf_theme_window_status_current_attr='bold'
              # tmux_conf_theme_window_status_current_format='#I #W'
              # #tmux_conf_theme_window_status_current_format='#{circled_window_index} #W'
              # #tmux_conf_theme_window_status_current_format='#I #W#{?window_zoomed_flag,🔍,}'

              # # window activity status style
              # tmux_conf_theme_window_status_activity_fg='default'
              # tmux_conf_theme_window_status_activity_bg='default'
              # tmux_conf_theme_window_status_activity_attr='underscore'

              # # window bell status style
              # tmux_conf_theme_window_status_bell_fg='#ffff00'         # yellow
              # tmux_conf_theme_window_status_bell_bg='default'
              # tmux_conf_theme_window_status_bell_attr='blink,bold'

              # # window last status style
              # tmux_conf_theme_window_status_last_fg='#E5E9F0'         # light blue
              # tmux_conf_theme_window_status_last_bg='default'
              # tmux_conf_theme_window_status_last_attr='none'

              # # status left/right sections separators
              # tmux_conf_theme_left_separator_main=' '
              # tmux_conf_theme_left_separator_sub='|'
              # tmux_conf_theme_right_separator_main=' '
              # tmux_conf_theme_right_separator_sub='|'
              # tmux_conf_theme_left_separator_main='\uE0B0'  # /!\ you don't need to install Powerline
              # tmux_conf_theme_left_separator_sub='\uE0B1'   #   you only need fonts patched with
              # tmux_conf_theme_right_separator_main='\uE0B2' #   Powerline symbols or the standalone
              # tmux_conf_theme_right_separator_sub='\uE0B3'  #   PowerlineSymbols.otf font, see README.md

              # # status left/right content:
              # #   - separate main sections with '|'
              # #   - separate subsections with ','
              # #   - built-in variables are:
              # #     - #{battery_bar}
              # #     - #{battery_hbar}
              # #     - #{battery_percentage}
              # #     - #{battery_status}
              # #     - #{battery_vbar}
              # #     - #{circled_session_name}
              # #     - #{hostname_ssh}
              # #     - #{hostname}
              # #     - #{loadavg}
              # #     - #{pairing}
              # #     - #{prefix}
              # #     - #{root}
              # #     - #{synchronized}
              # #     - #{uptime_y}
              # #     - #{uptime_d} (modulo 365 when #{uptime_y} is used)
              # #     - #{uptime_h}
              # #     - #{uptime_m}
              # #     - #{uptime_s}
              # #     - #{username}
              # #     - #{username_ssh}
              # tmux_conf_theme_status_left=' ❐ #S | ↑#{?uptime_y, #{uptime_y}y,}#{?uptime_d, #{uptime_d}d,}#{?uptime_h, #{uptime_h}h,}#{?uptime_m, #{uptime_m}m,} '
              # tmux_conf_theme_status_right='#{prefix}#{pairing}#{synchronized} #{?battery_status, #{battery_status},}#{?battery_bar, #{battery_bar},}#{?battery_percentage, #{battery_percentage},} , %R , %d %b , #(curl -m 1 wttr.in?format=1 2>/dev/null; sleep 900) | #{username}#{root} | #{hostname} '

              # # status left style
              # tmux_conf_theme_status_left_fg='#000000,#000000,#e4e4e4'  # black, white , white
              # tmux_conf_theme_status_left_bg='#81A1C1,#88C0D0,#E5E9F0'  # yellow, pink, white blue
              # tmux_conf_theme_status_left_attr='bold,none,none'

              # # status right style
              # tmux_conf_theme_status_right_fg='#e4e4e4,#e4e4e4,#000000' # light gray, white, black
              # tmux_conf_theme_status_right_bg='#3B4252,#434C5E,#88C0D0' # dark gray, red, white
              # tmux_conf_theme_status_right_attr='none,none,bold'

              # # pairing indicator
              # tmux_conf_theme_pairing='👓 '          # U+1F453
              # tmux_conf_theme_pairing_fg='none'
              # tmux_conf_theme_pairing_bg='none'
              # tmux_conf_theme_pairing_attr='none'

              # # prefix indicator
              # tmux_conf_theme_prefix='⌨ '            # U+2328
              # tmux_conf_theme_prefix_fg='none'
              # tmux_conf_theme_prefix_bg='none'
              # tmux_conf_theme_prefix_attr='none'

              # # root indicator
              # tmux_conf_theme_root='!'
              # tmux_conf_theme_root_fg='none'
              # tmux_conf_theme_root_bg='none'
              # tmux_conf_theme_root_attr='bold,blink'

              # # synchronized indicator
              # tmux_conf_theme_synchronized='🔒'     # U+1F512
              # tmux_conf_theme_synchronized_fg='none'
              # tmux_conf_theme_synchronized_bg='none'
              # tmux_conf_theme_synchronized_attr='none'

              # # battery bar symbols
              # tmux_conf_battery_bar_symbol_full='◼'
              # tmux_conf_battery_bar_symbol_empty='◻'
              # #tmux_conf_battery_bar_symbol_full='♥'
              # #tmux_conf_battery_bar_symbol_empty='·'

              # # battery bar length (in number of symbols), possible values are:
              # #   - auto
              # #   - a number, e.g. 5
              # tmux_conf_battery_bar_length='auto'

              # # battery bar palette, possible values are:
              # #   - gradient (default)
              # #   - heat
              # #   - 'colour_full_fg,colour_empty_fg,colour_bg'
              # tmux_conf_battery_bar_palette='gradient'
              # #tmux_conf_battery_bar_palette='#d70000,#e4e4e4,#000000'   # red, white, black

              # # battery hbar palette, possible values are:
              # #   - gradient (default)
              # #   - heat
              # #   - 'colour_low,colour_half,colour_full'
              # tmux_conf_battery_hbar_palette='gradient'
              # #tmux_conf_battery_hbar_palette='#d70000,#ff5f00,#5fff00'  # red, orange, green

              # # battery vbar palette, possible values are:
              # #   - gradient (default)
              # #   - heat
              # #   - 'colour_low,colour_half,colour_full'
              # tmux_conf_battery_vbar_palette='gradient'
              # #tmux_conf_battery_vbar_palette='#d70000,#ff5f00,#5fff00'  # red, orange, green

              # # symbols used to indicate whether battery is charging or discharging
              # tmux_conf_battery_status_charging='↑'       # U+2191
              # tmux_conf_battery_status_discharging='↓'    # U+2193
              # #tmux_conf_battery_status_charging='🔌'     # U+1F50C
              # #tmux_conf_battery_status_discharging='🔋'  # U+1F50B

              # # clock style (when you hit <prefix> + t)
              # # you may want to use %I:%M %p in place of %R in tmux_conf_theme_status_right
              # tmux_conf_theme_clock_colour='#E5E9F0'  # light blue
              # tmux_conf_theme_clock_style='24'

              # -- active pane decorations
              setw -g pane-border-status top # currently renders incorrectly in HEAD, top/off
              setw -g pane-border-format ""
              setw -g pane-border-format '─'

              setw -g pane-border-style 'bg=#323d43,fg=#555555'
              setw -g pane-active-border-style 'bg=#323d43,fg=blue'

              # dim inactive window text -- FIXME: failing when inactive set!
              # set -g window-style 'bg=#323d43,fg=#666666'
              set -g window-active-style 'bg=#323d43,fg=white'
              setw -g window-status-activity-style 'bg=red'
              set -g clock-mode-colour white
              set -g mode-style 'bg=#ffffff,fg=#000000'

              # colorize messages in the command line
              set -g status-style 'bg=default,fg=#aaaaaa'
              # Styling when in command mode i.e. vi or emacs mode in tmux command line
              set -g message-command-style 'fg=green bg=default bold,blink'
              # Regular tmux commandline styling
              set -g message-style 'fg=magenta bg=default italics,bold'

              # set -g message-style bg=default,fg=brightred #base02
              # set -g message-command-style bg=black,fg=blue

              # -- popup style
              # NOTE: had to alter fzf colors for my fzf scripts (disabling bg colours)
              set -g popup-style 'bg=#3f494e'
              set -g popup-border-style 'bg=#3f494e,fg=#3f494e' # #465258'
              set -g popup-border-lines 'padded'


              ###################################################################
              # Status bar
              ###################################################################

              # Set status bar on
              set -g status on

              # Update the status line every second
              set -g status-interval 1

              # Set the position of window lists.
              set -g status-justify centre # [left | centre | right]

              # Set Vi style keybinding in the status line
              set -g status-keys vi

              # Set the status bar position
              set -g status-position top # [top, bottom]

              # Set status bar background and foreground color.
              set -g status-style bg=default,fg=#aaaaaa

              # set -g status-position bottom
              set -g status-justify left

              # Set left side status bar length and style
              set -g status-left-length 60
              set -g status-left-style default

              # Display the session name
              set -g status-left "#[fg=#fffacd,bg=#3c474d] #{?client_prefix,,\uf490} #S #[fg=colour255,bg=default] ⋮ " # alts: 

              # Display the os version (Mac Os)
              # set -ag status-left " #[fg=black] #[fg=green,bright]  #(sw_vers -productVersion) #[default]"

              # Set right side status bar length and style
              set -g status-right-length 140
              set -g status-right-style default

              # Display the cpu load (Mac OS)
              # set -ag status-right "#[fg=green,bg=default,bright]  #(top -l 1 | grep -E "^CPU" | sed 's/.*://') #[default]"
              set -g status-right " #(top -l 1 | grep -E "^CPU" | sed 's/.*://' | awk -F \"%| \" '{print $2+$5 \"%\"}') #[default]"

              # Display the battery percentage (Mac OS)
              # set -ag status-left "#[fg=green,bg=default,bright] 🔋 #(pmset -g batt | tail -1 | awk '{print $3}' | tr -d ';') #[default]"
              set -ag status-right "⋮ #[fg=#a7c080,bg=default,nobold] #(pmset -g batt | tail -1 | awk '{print $3}' | tr -d ';') #[fg=colour255]"

              # Display the date
              # set -ag status-right "#[fg=white,bg=default]  %a %d #[default]"
              set -ag status-right "⋮ #[fg=white,bg=default]   %a %d #[default]"

              # Display the time
              # set -ag status-right "#[fg=colour172,bright,bg=default] ⌚︎%l:%M %p #[default]"
              set -ag status-right "⋮ #[fg=blue]%H:%M #[fg=colour250]#[fg=colour244](UTC #[fg=colour248]#(TZ='/usr/share/zoneinfo/UTC' date '+%%H:%%M')#[fg=colour244])#[bg=#323d43]#[fg=colour255] "

              # Display the hostname
              # set -ag status-right "#[fg=cyan,bg=default] ☠ #H #[default]"

              # Set the inactive window color and style
              set -g window-status-style fg=#415c6d
              set -g window-status-format '#{?window_zoomed_flag, ,○ }#I:#W '

              # Set the active window color and style
              set -g window-status-current-style bg=default,fg=blue
              set -g window-status-current-format '#{?window_zoomed_flag,#[italics]#[fg=red] ,#[italics,bold]#[fg=#323d43,bg=blue] }#I:#W '
            '';
          };
        };
      };
    };
}
