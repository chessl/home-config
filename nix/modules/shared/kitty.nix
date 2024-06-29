{ pkgs, lib, config, home-manager, options, ... }:

let

  cfg = config.my.modules.kitty;

in
{
  options = with lib; {
    my.modules.kitty = {
      enable = mkEnableOption ''
        Whether to enable kitty module
      '';
    };
  };

  config = with lib;
    mkIf cfg.enable (mkMerge [
      # imagemagick is required to show images in the terminal
      # (if (builtins.hasAttr "homebrew" options) then {
      #   homebrew.casks = [ "kitty" ];
      #   my.user = { packages = with pkgs; [ imagemagick ]; };
      # } else {
      #   my.user = { packages = with pkgs; [ kitty imagemagick ]; };
      # })

      # {
      #   my.env = {
      #     TERMINFO_DIRS = "$KITTY_INSTALLATION_DIR/terminfo";
      #   };

      #   my.hm.file = {
      #     ".config/kitty" = {
      #       recursive = true;
      #       source = ../../../config/kitty;
      #     };
      #   };
      # }
      {
        home-manager.users."${config.my.username}" = {
          programs = {
            kitty = {
              enable = true;
              # theme = "Everforest Dark Soft";
              darwinLaunchOptions = [
                "-o allow_remote_control=yes"
                "--single-instance"
                "--listen-on unix:/tmp/kitty-{kitty_pid}"
                # "--start-as=fullscreen"
              ];
              # font = {
              #   package = pkgs.monolisa;
              #   name = "Monolisa";
              #   size = 12;
              # };
              settings = {
                # --[ font ] ------------------------------------------------------------- {{{
                font_family = "MonoLisaVariable Nerd Font";
                bold_font = "auto";
                italic_font = "MonoLisaVariable Nerd Font Italic";
                bold_italic_font = "auto";
                font_size = "12.0";
                font_features = "MonoLisaVariableNF-Italic +ss02";
                #}}}
                # --[ cursor ] ------------------------------------------------------------- {{{
                # cursor = "none";
                # The cursor shape can be one of (block, beam, underline)
                # cursor_shape     block
                cursor_stop_blinking_after = "10.0";
                pointer_shape_when_dragging = "hand";
                #}}}

                # --[ mouse ] -------------------------------------------------------------- {{{
                copy_on_select = true;
                # -1 effectively means infinite scrollback
                scrollback_lines = 20000;
                # The modifiers to use rectangular selection (i.e. to select text in a
                # rectangular block with the mouse)
                # rectangle_select_modifiers ctrl+alt
                mouse_hide_wait = 15;
                # Set the active window to the window under the mouse when moving the mouse around
                focus_follows_mouse = true;
                #}}}

                # --[ bells ] -------------------------------------------------------------- {{{
                enable_audio_bell = false;
                # Makes the dock icon bounce on macOS or the taskbar flash on linux.
                window_alert_on_bell = false;
                #}}}

                # --[ windows ] ------------------------------------------------------------ {{{
                remember_window_size = true;
                # enabled_layouts = "tall:bias=55;tall:bias=50;full_size=1;stack;fat;grid;horizontal;split;mirrored=false;";
                enabled_layouts = "splits, fat, grid, horizontal, tall, vertical, stack";
                window_border_width = "1.0";
                window_margin_width = "0";
                # NOTE: t r b l
                window_padding_width = "12 12 12 12";
                placement_strategy = "top-left";
                inactive_text_alpha = "0.8";
                # (static,scale,size)
                resize_draw_strategy = "static";
                #}}}

                # --[ tabs ] --------------------------------------------------------------- {{{
                tab_bar_style = "custom";
                tab_separator = "\"\"";
                # REF: https://github.com/kovidgoyal/kitty/discussions/4447
                tab_fade = "0 0 0 0";
                tab_title_template = "{fmt.fg._415c6d}{fmt.bg.default}  {index}:{f'{title[:7]}…{title[-6:]}' if title.rindex(title[-1]) + 1 > 25 else title}{' [󰍉]' if layout_name == 'stack' else ''} ";
                active_tab_title_template = "{fmt.fg._83b6af}{fmt.bg.default}{fmt.bold} 󰻃 {index}:{f'{title[:6]}…{title[-6:]}' if title.rindex(title[-1]) + 1 > 25 else title}{' [󰍉]' if layout_name == 'stack' else ''} ";
                tab_bar_edge = "top";
                tab_bar_align = "left";
                tab_bar_margin_width = "0.0";
                tab_bar_margin_height = "10.0 10.0";
                active_tab_font_style = "bold-italic";
                inactive_tab_font_style = "normal";
                tab_bar_min_tabs = 1;
                tab_activity_symbol = "none";
                bell_on_tab = false;
                # or "🔔 "
                #}}}

                # --[ advanced ] ----------------------------------------------------------- {{{
                # HACK: passing environment variables to GUI applications in macOS is very hard
                # so this works around that by specifying the path to homebrew installations here
                # this only provides the $PATH not all the missing environment variables.
                # NOTE: this is wy nvim must be started inside this file using zsh -c 'nvim'
                # env PATH=/opt/homebrew/bin/:/usr/local/bin/:${PATH}

                # The shell program to execute. The default value of . means
                # to use whatever shell is set as the default shell for the current user.
                # Note that on macOS if you change this, you might need to add --login to
                # ensure that the shell starts in interactive mode and reads its startup rc files.
                # shell                           /usr/local/bin/zsh
                # shell_integration               disabled
                # allow_remote_control            yes
                # listen_on                       unix:/tmp/kitty
                # editor                          nvim
                # term                            xterm-kitty
                # single-instance                 yes
                #}}}

                # --[ sessions ] ----------------------------------------------------------- {{{
                # https://sw.kovidgoyal.net/kitty/overview/#startup-sessions
                # REF:
                # - https://dev.to/dylanirlbeck/kitty-sessions-44j2
                # - https://github.com/kovidgoyal/kitty/discussions/4066#discussioncomment-1390789 (troubleshooting with logging)
                # - https://github.com/dflock/kitty-save-session
                # - https://github.com/akinsho/phoenix-kitty
                # NOTE: nvim may need to be be started inside this file using zsh -c 'nvim'
                # startup_session                 ~/.dotfiles/config/kitty/sessions/default.conf
                # TODO: session switching via https://github.com/muchzill4/kitty-session
                #}}}

                # --[ os-specific ] -------------------------------------------------------- {{{
                draw_minimal_borders = false;
                hide_window_decorations = true;
                # Change the color of the kitty window's titlebar on macOS. A value of "system"
                # means to use the default system color, a value of "background" means to use
                # the background color of the currently active window and finally you can use
                # an arbitrary color, such as #12af59 or "red". WARNING: This option works by
                # using a hack, as there is no proper Cocoa API for it. It sets the background
                # color of the entire window and makes the titlebar transparent. As such it is
                # incompatible with background_opacity. If you want to use both, you are
                # probably better off just hiding the titlebar with macos_hide_titlebar.
                # Match one dark vim title bar background color
                macos_titlebar_color = "background";
                macos_hide_from_tasks = false;
                macos_traditional_fullscreen = true;
                macos_quit_when_last_window_closed = true;
                macos_thicken_font = "0.75";
                macos_custom_beam_cursor = true;
                # Use the option key as an alt key. With this set to no, kitty will use
                # the macOS native Option+Key = unicode character behavior. This will
                # break any Alt+key keyboard shortcuts in your terminal programs, but you
                # can use the macOS unicode input technique.
                macos_option_as_alt = true;
                macos_show_window_title_in = "window";
                # macos_colorspace                        displayp3
                #}}}

                # --[ includes ] ----------------------------------------------------------- {{{
                # You can include secondary config files via the "include" directive.
                # If you use a relative path for include, it is resolved with respect to the
                # location of the current config file. For example:
                # include ${HOME}/${USER}.conf
                # megaforest
                # include themes/megaforest.conf
                # color scheme (megaforest) ----------------------------------------------------

                # Font family. You can also specify different fonts for the
                # bold/italic/bold-italic variants.
                #

                url_color = "#0087BD";

                # The basic colors
                foregroung = "#cccccc";
                background = "#1e1e1e";
                selection_foreground = "#cccccc";
                selection_background = "#264f78";

                # Cursor colors
                cursor = "#ffffff";
                cursor_text_color = "#1e1e1e";

                # kitty window border colors
                active_border_color = "#e7e7e7";
                inactive_border_color = "#414140";

                # Tab bar colors
                active_tab_foreground = "#ffffff";
                active_tab_background = "#3a3d41";
                inactive_tab_foreground = "#858485";
                inactive_tab_background = "#1e1e1e";

                # black
                color0 = "#000000";
                color8 = "#666666";

                # red
                color1 = "#f14c4c";
                color9 = "#cd3131";

                # green
                color2 = "#23d18b";
                color10 = "#0dbc79";

                # yellow
                color3 = "#f5f543";
                color11 = "#e5e510";

                # blue
                color4 = "#3b8eea";
                color12 = "#2472c8";

                # magenta
                color5 = "#d670d6";
                color13 = "#bc3fbc";

                # cyan
                color6 = "#29b8db";
                color14 = "#11a8cd";

                # white
                color7 = "#e5e5e5";
                color15 = "#e5e5e5";
                #}}}

                # --[ misc ] --------------------------------------------------------------- {{{
                # or 0, 1, 2 (number of tabs)
                # REF: https://sw.kovidgoyal.net/kitty/conf/?highlight=margin#opt-kitty.confirm_os_window_close
                confirm_os_window_close = 0;
                dynamic_background_opacity = true;
                # url_style can be one of: none, single, double, curly
                url_style = "curly";
                #: The color and style for highlighting URLs on mouse-over. url_style
                #: can be one of: none, single, double, curly
                # open_url_modifiers = "super";
                #: The modifier keys to press when clicking with the mouse on URLs to
                #: open the URL
                open_url_with = "default";
                #: The program with which to open URLs that are clicked on. The
                #: special value default means to use the operating system's default
                #: URL handler.
                url_prefixes = "http https file ftp";
                #: The set of URL prefixes to look for when detecting a URL under the
                #: mouse cursor.
                # copy_on_select = true;
                #: Copy to clipboard or a private buffer on select. With this set to
                #: clipboard, simply selecting text with the mouse will cause the text
                #: to be copied to clipboard. Useful on platforms such as macOS that
                #: do not have the concept of primary selections. You can instead
                #: specify a name such as a1 to copy to a private kitty buffer
                #: instead. Map a shortcut with the paste_from_buffer action to paste
                #: from this private buffer. For example::
                #:     map cmd+shift+v paste_from_buffer a1
                #: Note that copying to the clipboard is a security risk, as all
                #: programs, including websites open in your browser can read the
                #: contents of the system clipboard.
                strip_trailing_spaces = "never";
                #: Remove spaces at the end of lines when copying to clipboard. A
                #: value of smart will do it when using normal selections, but not
                #: rectangle selections. always will always do it.
                # rectangle_select_modifiers = "ctrl+alt";
                #: The modifiers to use rectangular selection (i.e. to select text in
                #: a rectangular block with the mouse)
                # terminal_select_modifiers = "shift";
                #: The modifiers to override mouse selection even when a terminal
                #: application has grabbed the mouse
                select_by_word_characters = "@-./_~?&=%+#";

                sync_to_monitor = true;
                visual_bell_duration = 0;
                background_opacity = "1.0";
                # pointer_shape_when_dragging = "hand";
                # How much to dim text that has the DIM/FAINT attribute set. 1.0 means no dimming and
                # 0.0 means fully dimmed (i.e. invisible).
                dim_opacity = "0.90";
                allow_hyperlinks = true;
                close_on_child_death = true;
                allow_remote_control = true;
                clipboard_control = "write-clipboard write-primary read-clipboard";
                # term xterm-256color
                term = "xterm-kitty";
                # macos_hide_from_tasks = false;
                # macos_traditional_fullscreen = true;
                # macos_quit_when_last_window_closed = true;
                #
                # REF: https://github.com/kovidgoyal/kitty/issues/719#issuecomment-952039731
                # with a minimal config
                # scrollback_pager nvim --noplugin -u ~/.config/kitty/scrollback-pager/nvim/init.vim -c "silent write! /tmp/kitty_scrollback_buffer | te cat /tmp/kitty_scrollback_buffer - "
                # with a minimal no-config
                # scrollback_pager nvim -c "set norelativenumber nonumber nolist showtabline=0 foldcolumn=0" -c "autocmd TermOpen * normal G" -c "silent! write! /tmp/kitty_scrollback_buffer | te cat /tmp/kitty_scrollback_buffer - "
                # scrollback_pager nvim -c 'setlocal number norelativenumber nolist showtabline=0 foldcolumn=0|Man!' -c "autocmd VimEnter * normal G" -

                # REF: https://github.com/kristijanhusak/neovim-config/blob/master/kitty/kitty.conf#L21
                scrollback_pager = "nvim --noplugin -u NONE -c 'runtime plugin/man.vim|Man!' -c \"autocmd VimEnter * normal G\" -c \"nnoremap Q :qa!<CR>\" -";

                # macos_thicken_font = "1.1";
                # tab_activity_symbol = "▲";
                # cursor_stop_blinking_after = 0;
                # scrollback_lines = 20000;
                # scrollback_fill_enlarged_window = true;
                # copy_on_select = false;
                # select_by_word_characters = ":@-./_~?&=%+#";
                # mouse_hide_wait = 0;
                # window_alert_on_bell = false;
                # enable_audio_bell = false;
                # remember_window_size = true;
                # window_padding_width = 10;
                # tab_bar_edge = "top";
                # close_on_child_death = false;
                # allow_remote_control = true;
                # hide_window_decorations = true;
                # macos_titlebar_color = "system";
                # macos_option_as_alt = true;
                # macos_hide_from_tasks = false;
                # macos_traditional_fullscreen = true;
                # macos_custom_beam_cursor = true;
                # macos_colorspace = "displayp3";
                # strip_trailing_spaces = "smart";
                # update_check_interval = 0;
                # url_style = "curly";
                # shell_integration = "disabled";
                # inactive_text_alpha = "0.6";
                # term xterm-kitty
                # clipboard_control = "write-clipboard write-primary no-append";
                # confirm_os_window_close = 0;
                # For a list of key names, see: http://www.glfw.org/docs/latest/group__keys.html
                # For a list of modifier names, see: http://www.glfw.org/docs/latest/group__mods.html
                # super == cmd on mac
                # kitty_mod = "ctrl+a";
                # You can have kitty remove all shortcut definition seen upto this point. Useful for
                # instance, to remove the default shortcuts.
                # clear_all_shortcuts = false;
              };

              keybindings = {
                # Clipboard
                # "kitty_mod+s" = "paste_from_selection";
                # "shift+insert" = "paste_from_selection";
                # "kitty_mod+o" = "pass_selection_to_program";

                # Scrolling
                # "kitty_mod+shift+h" = "show_scrollback";

                # Window management
                "super+n" = "new_os_window";
                # "kitty_mod+w" = "close_window";
                "ctrl+q>|" = "launch --location=vsplit --cwd=last_reported";
                "ctrl+q>-" = "launch --location=hsplit --cwd=last_reported";
                "ctrl+q>z" = "toggle_layout stack";
                "ctrl+q>h" = "neighboring_window left";
                "ctrl+q>j" = "neighboring_window bottom";
                "ctrl+q>k" = "neighboring_window top";
                "ctrl+q>l" = "neighboring_window right";
                "ctrl+q>space" = "layout_action rotate";

                "ctrl+q>shift+h" = "resize_window narrower";
                "ctrl+q>shift+l" = "resize_window wider";
                "ctrl+q>shift+j" = "resize_window taller";
                "ctrl+q>shift+k" = "resize_window shorter";

                # "kitty_mod+`" = "move_window_to_top";

                # Tab management
                "ctrl+tab" = "next_tab";
                "ctrl+shift+tab" = "previous_tab";
                "super+shift+]" = "next_tab";
                "super+shift+[" = "previous_tab";
                "super+t" = "new_tab_with_cwd";
                "super+w" = "close_tab";
                # "kitty_mod+l" = "next_layout";
                "super+[" = "move_tab_forward";
                "super+]" = "move_tab_backward";
                "ctrl+q>," = "set_tab_title";
                "super+1" = "goto_tab 1";
                "super+2" = "goto_tab 2";
                "super+3" = "goto_tab 3";
                "super+4" = "goto_tab 4";
                "super+5" = "goto_tab 5";
                "super+6" = "goto_tab 6";
                "super+7" = "goto_tab 7";
                "super+8" = "goto_tab 8";
                "super+9" = "goto_tab 9";

                "ctrl+q>b" = "launch --allow-remote-control kitty +kitten broadcast --match-tab state:focused";

                # scrollback
                "ctrl+q>[" = "launch --stdin-source=@screen_scrollback --stdin-add-formatting less +G -R";

                # Select and act on visible text {{{
                # Use the hints kitten to select text and either pass it to an external program or
                # insert it into the terminal or copy it to the clipboard.
                #
                # Open a currently visible URL using the keyboard. The program used to open the
                # URL is specified in open_url_with.
                # "kitty_mod+e" = "run_kitten text hints";

                # Select a path/filename and insert it into the terminal. Useful, for instance to
                # run git commands on a filename output from a previous git command.
                # "kitty_mod+p>f" = "run_kitten text hints --type path --program -";

                # Select a path/filename and open it with the default open program.
                # "kitty_mod+p>shift+f" = "run_kitten text hints --type path";

                # Select a line of text and insert it into the terminal. Use for the
                # output of things like: ls -1
                # "kitty_mod+p>l" = "run_kitten text hints --type line --program -";

                # Select words and insert into terminal.
                # "kitty_mod+p>w" = "run_kitten text hints --type word --program -";

                # The hints kitten has many more modes of operation that you can map to different
                # shortcuts. For a full description run: kitty +kitten hints --help
                # }}}

                # Miscellaneous
                # "kitty_mod+u" = "input_unicode_character";
                # "kitty_mod+escape" = "kitty_shell window";

                # Send F6 for Ctrl-i in Vim (code via `kitty --debug-keyboard`).
                # "ctrl+i" = "send_text application \x48";
              };

              extraConfig = ''
                # These are not broken after 0.21.0
                # https://github.com/kovidgoyal/kitty/issues/3718
                mouse_map super+left press grabbed mouse_discard_event
                mouse_map super+left release grabbed,ungrabbed mouse_handle_click link
                mouse_map super+alt+left press ungrabbed mouse_selection rectangle

                mouse_map right press ungrabbed mouse_select_command_output
              '';
            };
          };
        };

        my.hm.file = {
          ".config/kitty" = {
            recursive = true;
            source = ../../../config/kitty;
          };
        };
      }
    ]);
}
