# This is handcrafted setup to keep the same performance characteristics I had
# before using nix or even improve it. Simple rules followed here are:
#
# - Setup things as early as possible when the shell runs
# - Inline files when possible instead of souring then
# - User specific shell files are to override or for machine specific setup

{ pkgs, lib, home-manager, config, options, ... }:

let

  cfg = config.my.modules.shell;
  inherit (config.my.user) home;
  inherit (config.my) hm;
  inherit (config.my) hostConfigHome;

  local_zshrc = "${hostConfigHome}/zshrc";

  darwinPackages = with pkgs; [
    openssl
    gawk
    gnugrep
    gnused
    coreutils-full
    moreutils
    findutils
    binutils
    inetutils
    diffutils
    tree
  ];
  nixosPackages = with pkgs; [ dwm dmenu xclip ];
in {
  options = with lib; {
    my.modules.shell = {
      enable = mkEnableOption ''
        Whether to enable shell module
      '';
    };
  };

  config = with lib;
    mkIf cfg.enable (mkMerge [

      {

        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment = {
          shells = [ pkgs.bashInteractive pkgs.zsh pkgs.fish ];
          loginShell = "${pkgs.bashInteractive}";
          loginShellInit = ''
            # https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1266049484
            export $PATH = $(echo $NIX_PROFILES | sed -e "s/ /:/g"):$PATH;
          '';
          shellInit = ''
            # https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1266049484
            export $PATH = $(echo $NIX_PROFILES | sed -e "s/ /:/g"):$PATH;
            BLK="0B" CHR="0B" DIR="04" EXE="06" REG="00" HARDLINK="06" SYMLINK="06" MISSING="00" ORPHAN="09" FIFO="06" SOCK="0B" OTHER="06"
            export NNN_FCOLORS="$BLK$CHR$DIR$EXE$REG$HARDLINK$SYMLINK$MISSING$ORPHAN$FIFO$SOCK$OTHER"
          '';
          shellAliases = {
            # https://xenodium.com/a-lifehack-for-your-shell/
            unzip = "atool --extract --explain $1";
            t = "tmux -2";
            tmux = "tmux -2";
            "cd.." = "cd ..";
            ".." = "cd ..";
            mkdirp = "mkdir -p";
            px = "proxychains4";
            lcurl = "curl --noproxy localhost";
            topcpu = "ps -eo pid,ppid,cmd,%mem,%cpu -r | head";
            topmem = "ps -eo pid,ppid,cmd,%mem,%cpu -m | head";
            ssh = "kitty +kitten ssh";
            s = "kitty +kitten ssh";
            ssctl =
              "SEASTAR_ADDR=https://sscontroller.alipay.com ~/.ssctl/bin/ssctl";
            ",apply" =
              "nix --experimental-features 'nix-command flakes' flake update && nix --experimental-features 'nix-command flakes' build ~/Developer/home-config/#$(hostname) && ~/Developer/home-config/result/sw/bin/darwin-rebuild switch --flake ~/Developer/home-config/#$(hostname)";
          };
          variables = {
            XDG_CACHE_HOME = hm.cacheHome;
            XDG_CONFIG_HOME = hm.configHome;
            XDG_DATA_HOME = hm.dataHome;
            XDG_STATE_HOME = hm.stateHome;
            HOST_CONFIGS = "${hostConfigHome}";
            # https://github.blog/2022-04-12-git-security-vulnerability-announced/
            GIT_CEILING_DIRECTORIES = builtins.dirOf home;

            # https://consoledonottrack.com/
            # Future proof
            DO_NOT_TRACK = "1";

            FONTCONFIG_FILE = "${pkgs.fontconfig.out}/etc/fonts/fonts.conf";
            FONTCONFIG_PATH = "${pkgs.fontconfig.out}/etc/fonts/";
            # FONTCONFIG_FILE = "${hm.configHome}/fontconfig/conf.d/10-hm-fonts.conf";
            # FONTCONFIG_PATH = "${hm.configHome}/fontconfig/conf.d/";

          };
          systemPath = [ "/opt/homebrew/bin" "~/.cargo/bin" ];
          systemPackages = with pkgs;
            (if stdenv.isDarwin then darwinPackages else nixosPackages) ++ [
              curl
              wget
              bash-completion
              nix-bash-completions
              yarn-bash-completion
              zsh-completions
              zsh-better-npm-completion
              nix-zsh-completions
              rsync
              ffmpeg
              imagemagick
              proxychains-ng # proxy
              atool # Archive command line helper
              pv # Tool for monitoring the progress of data through a pipeline
              gtypist
              nixd # nix lsp
              nixfmt-classic # nix formatter
            ];
        };

        my = {
          user = {
            shell = if pkgs.stdenv.isDarwin then
              [ pkgs.bashInteractive ]
            else
              pkgs.bashInteractive;
            packages = with pkgs; [
              hyperfine # Benchmarking tool
              grc # Generic colouriser
              lnav # System Log file navigator
              scc # code counter
              graph-easy # convert graph to ASCII
              graphviz
              difftastic
              vale # prose linter
              entr # Event Notify Test Runner
              vivid # generator for LS_COLORS
              pastel # color manipulator
              hostctl # /etc/hosts management
              nerd-font-patcher
            ];
          };
        };

        system.activationScripts.postUserActivation.text = ''
          # Set the default shell as bash for the user. MacOs doesn't do this like nixOS does
          sudo chsh -s ${
            lib.getBin pkgs.bashInteractive
          }/bin/bash ${config.my.username}
        '';

        programs = {
          bash = { enable = true; };

          zsh = { enable = true; };

          fish = { enable = true; };

          nix-index = { enable = true; };
        };

        home-manager.users."${config.my.username}" = {
          programs = {
            nix-index = {
              enable = true;
              enableBashIntegration = true;
              enableZshIntegration = true;
              enableFishIntegration = true;
            };

            bash = {
              enable = true;
              enableVteIntegration = true;
              historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
              historySize = 500000;
              historyFileSize = 100000;
              historyIgnore = [
                # "&"
                # "[ ]*"
                "ls"
                "exit"
                "bg"
                "fg"
                "history"
                "clear"
              ];

              shellOptions = [
                # Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
                "checkwinsize"
                # Case-insensitive globbing (used in pathname expansion)
                "nocaseglob"
                # Turn on recursive globbing (enables ** to recurse all directories)
                "globstar 2> /dev/null"
                # Causes bash to append to history instead of overwriting it so if you start a new terminal, you have old session history
                "histappend"
                # Save multi-line commands as one command
                "cmdhist"
                # Prepend cd to directory names automatically
                "autocd 2> /dev/null"
                # Correct spelling errors during tab-completion
                "dirspell 2> /dev/null"
                # Correct spelling errors in arguments supplied to cd
                "cdspell 2> /dev/null"
                # This allows you to bookmark your favorite places across the file system
                # Define a variable containing a path and you will be able to cd into it regardless of the directory you're in
                "cdable_vars"
              ];

              profileExtra = ''
                                ## GENERAL OPTIONS ##

                                # Supress "Bash no longer supported" message
                                BASH_SILENCE_DEPRECATION_WARNING=1

                                # Always display the error code unless it’s 0
                                prompt_show_ec () {
                                 # Catch exit code
                                 ec=$?
                                 # Display exit code in red text unless zero
                                 if [ $ec -ne 0 ];then
                                  echo -e "\033[31;1m[$ec]\033[0m"
                                 fi
                                }
                                PROMPT_COMMAND="prompt_show_ec; $PROMPT_COMMAND"

                                # To have colors for ls and all grep commands such as grep, egrep and zgrep
                                CLICOLOR=1
                                LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;
                31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;3
                5:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg
                =01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'
                                # Color for manpages in less makes manpages a little easier to read
                                LESS_TERMCAP_mb=$'\E[01;31m'
                                LESS_TERMCAP_md=$'\E[01;31m'
                                LESS_TERMCAP_me=$'\E[0m'
                                LESS_TERMCAP_se=$'\E[0m'
                                LESS_TERMCAP_so=$'\E[01;44;33m'
                                LESS_TERMCAP_ue=$'\E[0m'
                                LESS_TERMCAP_us=$'\E[01;32m'

                                # Prevent file overwrite on stdout redirection
                                # Use `>|` to force redirection to an existing file
                                set -o noclobber

                                # Automatically trim long paths in the prompt (requires Bash 4.x)
                                PROMPT_DIRTRIM=2

                                # Enable history expansion with space
                                # E.g. typing !!<space> will replace the !! with your last command
                                bind Space:magic-space

                                ## SMARTER TAB-COMPLETION (Readline bindings) ##
                                # Perform file completion in a case insensitive fashion
                                bind "set completion-ignore-case on"

                                # Treat hyphens and underscores as equivalent
                                bind "set completion-map-case on"

                                # Display matches for ambiguous patterns at first tab press
                                bind "set show-all-if-ambiguous on"

                                # Immediately add a trailing slash when autocompleting symlinks to directories
                                bind "set mark-symlinked-directories on"

                                ## SANE HISTORY DEFAULTS ##

                                # Record each line as it gets issued
                                # PROMPT_COMMAND='history -a; $PROMPT_COMMAND'

                                # Use standard ISO 8601 timestamp
                                # %F equivalent to %Y-%m-%d
                                # %T equivalent to %H:%M:%S (24-hours format)
                                HISTTIMEFORMAT='%F %T '

                                # Enable incremental history search with up/down arrows (also Readline goodness)
                                # Learn more about this here: http://codeinthehole.com/writing/the-most-important-command-line-tip-incremental-history-searching-with-inputrc/
                                bind '"\e[A": history-search-backward'
                                bind '"\e[B": history-search-forward'
                                bind '"\e[C": forward-char'
                                bind '"\e[D": backward-char'


                                ## BETTER DIRECTORY NAVIGATION ##
                                # This defines where cd looks for targets
                                # Add the directories you want to have fast access to, separated by colon
                                # Ex: CDPATH=".:~:~/projects" will look for targets in the current working directory, in home and in the ~/projects folder
                                CDPATH="."

                                # Free up ctrl+s and ctrl+q
                                stty -ixon -ixoff

                                # Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
                                [ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

                                # Add tab completion for `defaults read|write NSGlobalDomain`
                                # You could just use `-g` instead, but I like being explicit
                                complete -W "NSGlobalDomain" defaults;

                                # Ignore case on auto-completion
                                # Note: bind used instead of sticking these in .inputrc
                                if [[ $iatest > 0 ]]; then bind "set completion-ignore-case on"; fi

                                # Show auto-completion list automatically, without double tab
                                if [[ $iatest > 0 ]]; then bind "set show-all-if-ambiguous On"; fi
              '';

            };

            zsh = {
              enable = true;
              enableCompletion = true;
              autosuggestion.enable = true;
              syntaxHighlighting.enable = true;
              enableVteIntegration = true;
              autocd = true;
              history = {
                expireDuplicatesFirst = true;
                extended = true;
                ignoreDups = true;
                ignoreSpace = true;
                save = 1000000;
                share = true;
                size = 1000000;
                ignorePatterns = [ "ls *" "exit" "bg" "fg" "history" "clear" ];
              };
              completionInit =
                "autoload -U promptinit; promptinit; prompt pure";
            };

            fish = {
              enable = true;
              loginShellInit = ''
                set fish_greeting
                # for p in (string split " " $NIX_PROFILES); fish_add_path --prepend --move $p/bin; end
              '';
            };

            carapace = {
              enable = true;
              enableBashIntegration = true;
              enableZshIntegration = true;
              enableFishIntegration = true;
            };

            dircolors = {
              enable = true;
              enableBashIntegration = true;
              enableZshIntegration = true;
              enableFishIntegration = true;
            };

            starship = {
              enable = true;
              enableBashIntegration = true;
              enableZshIntegration = true;
              enableFishIntegration = true;
            };

            jq = { enable = true; };

            pandoc = { enable = true; };

            readline = {
              enable = true;
              variables = {
                # Allow UTF-8 input and output, instead of showing stuff like $'\0123\0456'
                input-meta = "on";
                output-meta = "on";
                convert-meta = "off";

                # show all completion instead of ringing the bell
                show-all-if-ambiguous = "on";
                show-all-if-unmodified = "on";

                # single tab instead of double tab
                visible-stats = "on";

                page-completions = "off";
                completion-ignore-case = "on";

                # completion respects LS_COLORS
                colored-stats = "on";

                # symbolic link with slash appended
                mark-symlinked-directories = "on";

                completion-prefix-display-length = "3";
                expand-tilde = "on";
                # editing-mode = "vi";
              };
            };

            fzf = {
              enable = true;
              enableBashIntegration = true;
              enableZshIntegration = true;
              enableFishIntegration = true;
              tmux.enableShellIntegration = true;
            };

            atuin = {
              enable = true;
              enableBashIntegration = true;
              enableZshIntegration = true;
              enableFishIntegration = true;
              settings = {
                update_check = false;
                search_mode = "prefix";
              };
            };

            nnn = {
              enable = true;
              package = pkgs.nnn.override { withNerdIcons = true; };
              plugins = {
                mappings = {
                  f = "finder";
                  p = "preview-tui";
                  v = "imgview";
                };
              };
              bookmarks = {
                d = "~/Documents";
                D = "~/Downloads";
                p = "~/Pictures";
                h = "~";
                c = "~/.config";
                m = "~/Music";
                v = "~/Videos";
              };

            };

            bottom = { enable = true; };

            ripgrep = { enable = true; };

            direnv = {
              enable = true;
              enableBashIntegration = true;
              enableZshIntegration = true;
              nix-direnv.enable = true;
              config = { theme = "ansi-dark"; };
            };

            htop = { enable = true; };

            zoxide = {
              enable = true;
              enableBashIntegration = true;
              enableZshIntegration = true;
              enableFishIntegration = true;
            };

            lesspipe.enable = true;

            lsd = {
              enable = true;
              enableAliases = true;
            };

            yazi = {
              enable = true;
              enableBashIntegration = true;
              enableZshIntegration = true;
              enableFishIntegration = true;
              keymap = {
                input.keymap = [
                  {
                    exec = "close";
                    on = [ "<C-q>" ];
                  }
                  {
                    exec = "close --submit";
                    on = [ "<Enter>" ];
                  }
                  {
                    exec = "escape";
                    on = [ "<Esc>" ];
                  }
                  {
                    exec = "backspace";
                    on = [ "<Backspace>" ];
                  }
                ];
                manager.keymap = [
                  {
                    exec = "escape";
                    on = [ "<Esc>" ];
                  }
                  {
                    exec = "quit";
                    on = [ "q" ];
                  }
                  {
                    exec = "close";
                    on = [ "<C-q>" ];
                  }
                ];
              };
              settings = {
                log = { enabled = false; };
                manager = {
                  show_hidden = false;
                  sort_by = "modified";
                  sort_dir_first = true;
                  sort_reverse = true;
                };
              };
              theme = {
                filetype = {
                  rules = [
                    {
                      fg = "#7AD9E5";
                      mime = "image/*";
                    }
                    {
                      fg = "#F3D398";
                      mime = "video/*";
                    }
                    {
                      fg = "#F3D398";
                      mime = "audio/*";
                    }
                    {
                      fg = "#CD9EFC";
                      mime = "application/x-bzip";
                    }
                  ];
                };
              };
            };

            translate-shell = {
              enable = true;
              settings = {
                hl = "en";
                tl = "zh";
                verbose = true;
              };
            };
          };
        };
      }
    ]);

}
