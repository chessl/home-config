{ pkgs, lib, home-manager, config, inputs, ... }:

with config.my;

let
  cfg = config.my.modules.vim;
  inherit (config.my.user) home;
in {
  options = with lib; {
    my.modules.vim = {
      enable = mkEnableOption ''
        Whether to enable vim module
      '';
    };
  };

  config = with lib;
    mkIf cfg.enable {
      environment.systemPackages = with pkgs;
        [
          # vim
          neovim
          ninja # used to build lua-language-server
        ] ++ (lib.optionals (!pkgs.stdenv.isDarwin) [
          gcc # Requried for treesitter parsers
        ]);

      home-manager.users."${config.my.username}" = {
        programs = {
          vim = {
            enable = true;
            settings = {
              number = true;
              relativenumber = true;
              # Allows hiding buffers even though they contain modifications which have not yet been written back to the associated file. (sounds quite technical, eh?)
              hidden = true;
            };
            extraConfig = ''
              " This changes the values of a LOT of options, enabling features which are not Vi compatible but really really nice.
              set nocp

              " Enables input of special characters by a combination of two characters. Example: Type 'a', erase it by typing CTRL-H - and then type ':' - this results in the umlaut: ä So Vim remembers the character you have erased and combines it with the character you have typed "over" the previos one.
              set digraph

              " Enables recognition of arrow key codes which start off with an ESC. This would normally end your current mode (insert/append/open mode) and return you command mode (aka normal mode), and the rest of the code would trigger commands. bah! Although I dont use the arrow keys often, I sometimes want to use them with replace mode and virtual editing And I don't want to be *that* compatible to vanilla vi, anyway. (so sue me).
              set ek

              " Shows the "ruler" for the cursor, ie its current position with line+column and the percentage within the buffer. This saves me typing CTRL-G (or better "g CTRL-G") - and many users like this feature, too. And it is nice when showing Vim.
              set ru

              " Show the input of an *incomplete* command. So while you are typing the command "y23dd you will see "y23dd before you type the last 'd' which completes the command. Makes learning Vi much simpler as you get some feedback to what you have already typed.
              set sc

              " Chose "visual bell" effect rather than "beeping".
              set vb

              " Make use of the "status line" to show possible completions of command line commands, file names, and more. Allows to cycle forward and backward throught the list. This is called the "wild menu".
              set wmnu

              " Turn off the bell. You do know the "beep" you get when you type ESC in normal mode? Be nice to your co-workers - turn it off! ;-)
              set noeb

              " When inserting text do not expand TABs to spaces. While I try to avoid all control characters in text I can make good use of TABs when typing a table. And I know I can always make Vim expand the TABs later (using the ":retab" command). Your mileage may vary..
              set noet

              " Prevent the cursor from changing the current column when jumping to other lines within the window. (And if you like that then you'll "virtual editing" with Vim-6! :-)
              set nosol

              " Automatic indentation. This automatically inserts the indentation from the current line when you start a new line; in insert mode you would start a new line by ending the current one by inserting CTRL-J or CTRL-M - and in command mode you'd "open" a new line with either 'o' or 'O' for below or above the current line, respectively. By the way, "autoindent" is actually a feature of vanilla vi.
              set ai

              " Backspace with this value allows to use the backspace character (aka CTRL-H or "<-") to use for moving the cursor over automatically inserted indentation and over the start/end of line. (see also the whichwrap option)
              set bs=2

              " The formatoptions affect the built-in "text formatting" command. The default value omits the "flag" 'r' which makes Vim insert a "comment leader" of the line when starting a new one. This allows to add text to a comment and still be within the comment after you start a new line. It also allows to break the line within a comment without breaking the comment.
              set fo=cqrt

              " This makes Vim show a status line even when only one window is shown. Who said a status line is only useful to separate multiple windows?
              set ls=2

              " This shortens about every message to a minimum and thus avoids scrolling within the output of messages and the "press a key" prompt that goes with these.
              set shm=at

              " This explicitly sets the width of text to 72 characters. After each completion of a word in insert mode Vim checks whether its end is past this width; if so then it will break the word onto the next line. Note that Vim will remove trailing spaces when applying the word wrap - a feature which many editors are missing (and which will leave trailing spaces, of course). NOTE: The word wrap applies only when the *completed* word goes over the line; when you insert a word before that which moves other words over the line then Vim will *not* break the words at the end of the line onto the next line! Programmers certainly don't want that. It's a feature!!
              set tw=72

              " There are several commands which move the cursor within the line. When you get to the start/end of a line then these commands will fail as you cannot go on. However, many users expect the cursor to be moved onto the previous/next line. Vim allows you to chose which commands will "wrap" the cursor around the line borders. Here I allow the cursor left/right keys as well as the 'h' and 'l' command to do that.
              set ww=<,>,h,l

              " Vim can reformat text and preserve comments (commented lines) even when several kinds of comment indentation "nest" within. (This is very useful for reformatting quoted text in Email and News.) But you need to tell Vim how the comments look like. Usually a comment starts off with some string, which may require a following blank. Comments may also span over lines by starting off with some string, skipping some middle part, and then end with another string (think about comments in C++, for example). I simply removed the "/* foo */" commenting from the default value and added that ')' can also be "nested comments".
              set com=b:#,:%,n:>

              " This option is cool! Or let's say that "other editors don't have that at all." These characters are called "list characters" as they are related to the list option of vanilla vi: This will show the end-of-lines by adding a '$' sign after the last character of each line, and by replacing all TABs by '^I'. However, it is much nicer to still have TABs shown in expanded form. Vim takes it one step further by also making trailing spaces visible. Being able to see EOLs, TABs, and trailing space has become an absolute MUST with every editor.
              set list
              set lcs=tab:»·
              set lcs+=trail:·

              " The idea of "viminfo" is to save info from one editing session for the next by saving the data in an "viminfo file". So next time I satrt up Vim I can use the search patterns from the search history and the commands from the command line again. I can also load files again with a simple ":b bufname". And Vim also remember where the cursor was in the files I edited. See ":help viminfo" for more info on Vim's "viminfo". :-}
              set vi=%,'50
              set vi+=\"100,:100
              set vi+=n~/.viminfo
            '';
          };
        };
      };

      my = {
        env = rec {
          EDITOR = "${pkgs.neovim}/bin/nvim";
          VISUAL = "$EDITOR";
          GIT_EDITOR = "$EDITOR";
          MANPAGER = "$EDITOR +Man!";
        };

        hm.configFile = {
          nvim = {
            source = ./config;
            recursive = true;
          };
        };
      };
      environment.shellAliases.e = "$EDITOR --listen /tmp/nvim.pipe";

      my.user = {
        packages = with pkgs; [
          fzf
          par
          fd
          ripgrep
          # editorconfig-checker # do I use it?
          hadolint # Docker linter
          nixpkgs-fmt
          vim-vint
          shellcheck
          shfmt # Doesn't work with zsh, only sh & bash
          stylua
          # nodePackages.neovim
          # nodePackages.vscode-langservers-extracted # HTML, CSS, JSON & ESLint LSPs
          # nodePackages.prettier
          # nodePackages.bash-language-server
          # nodePackages.dockerfile-language-server-nodejs
          # nodePackages.typescript-language-server
          # nodePackages.typescript
          # nodePackages.eslint
          # nodePackages.eslint_d
          # nodePackages.vim-language-server
          # nodePackages.pyright
          # nodePackages.yaml-language-server
          # nodePackages."@tailwindcss/language-server"
          selene # Lua linter
          statix
          # nix-linter # Until statix pick up, see https://github.com/nerdypepper/statix/issues/18
          sumneko-lua-language-server
          gopls # Go language server
          commitlint
          editorconfig-checker
        ];
      };

    };
}
