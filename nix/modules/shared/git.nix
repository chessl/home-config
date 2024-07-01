{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.my.modules.git;
  includeModule = types.submodule ({ config, ... }: {
    options = {
      condition = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Include this configuration only when {var}`condition`
          matches. Allowed conditions are described in
          {manpage}`git-config(1)`.
        '';
      };

      path = mkOption {
        type = with types; either str path;
        description = "Path of the configuration file to include.";
      };

      contents = mkOption {
        type = types.attrsOf types.anything;
        default = { };
        example = literalExpression ''
          {
            user = {
              email = "bob@work.example.com";
              name = "Bob Work";
              signingKey = "1A2B3C4D5E6F7G8H";
            };
            commit = {
              gpgSign = true;
            };
          };
        '';
        description = ''
          Configuration to include. If empty then a path must be given.

          This follows the configuration structure as described in
          {manpage}`git-config(1)`.
        '';
      };

      contentSuffix = mkOption {
        type = types.str;
        default = "gitconfig";
        description = ''
          Nix store name for the git configuration text file,
          when generating the configuration text from nix options.
        '';

      };
    };
    config.path = mkIf (config.contents != { }) (mkDefault
      (pkgs.writeText (hm.strings.storeFileName config.contentSuffix)
        (generators.toGitINI config.contents)));
  });
in
{
  options = {
    my.modules.git = {
      enable = mkEnableOption ''
        Whether to enable git module
      '';
      username = mkOption {
        default = config.my.username;
        type = with types; uniq str;
      };
      includes = mkOption {
        default = [ ];
        type = with types; listOf includeModule;
      };
    };
  };

  config = mkIf cfg.enable {
    home-manager.users."${config.my.username}" = {
      programs = {
        git = {
          enable = true;

          lfs.enable = true;

          userName = config.my.name;
          userEmail = config.my.email;

          inherit (cfg) includes;

          delta = {
            enable = true;
            options = {
              theme = "Nord";
              # syntax-theme = "Forest Night";
              features = "side-by-side line-numbers decorations";
              whitespace-error-style = "22 reverse";
              decorations = {
                commit-decoration-style = "bold yellow box ul";
                file-style = "bold yellow ul";
                file-decoration-style = "none";
              };
            };
          };

          # signing.key = "";

          aliases = {
            aa = "add --all :/";
            ap = "add --patch";
            c = "commit";
            cv = "commit -v";
            cm = "commit -m";
            ca = "commit --amend";
            cp = "commit -p";
            co = "checkout";
            cl = "clone";
            b = "branch";
            br = "branch";
            cons = "!git ls-files -u | cut -f 2 | sort -u";
            econs = "!git diff --name-only --diff-filter=U | uniq | xargs $EDITOR";
            dangled = "!git fsck --no-reflog | awk '/dangling commit/ {print $3}'";
            cr = "!git-crypt";
            d = "diff";
            ds = "diff --staged";
            di = "diff";
            dc = "diff --cached";
            df = "diff";
            s = "status -sb";
            st = "status";
            subpull = "submodule foreach git pull";
            r = "restore";
            rs = "restore --staged";
            pick = "cherry-pick";
            tree = "log --graph --pretty=oneline --decorate";
            undo = "reset --soft HEAD^";
            uncommit = "reset --soft HEAD^";
            unamend = "reset --soft HEAD@{1}";
            abort = "reset --hard HEAD^";
            head = "!git l -1";
            last = "!git log --max-count=1 | awk '{print $2}' | awk 'NR==1{print $1}'";
            log = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
            up = "!git pull --autostash --rebase && git log --color --pretty=oneline --abbrev-commit HEAD@{1}.. | sed 's/^/  /'";

            aliases = "!git config -l | grep ^alias | cut -c 7- | sort";


            # find commits that changed a file: git his <filepath>
            his = "log --follow --color=always --date=format:'%d %b, %Y' --pretty=format:'(%Cgreen%h%Creset)[%ad] %C(blue bold)%s%Creset'";
            # search code in commit history: git wot :function_name:filepath
            wot = "log --date=format:'%d %b, %Y' --pretty='%n%C(yellow bold)📅️ %ad%Creset by (%C(green bold)%an%Creset) %C(cyan bold)%h%Creset' --graph -L";
            # top 10 most edited files
            top10 = "! git log --pretty=format: --name-only | sort | uniq -c | sort -rg | head -10";
          };

          extraConfig = {
            clean.requireForce = true;
            mergetool = {
              prompt = true;
              nvimdiff = {
                keepBackup = false;
                cmd = "nvim -d \"$LOCAL\" \"$MERGED\" \"$REMOTE\"";
                trustExitCode = true;
              };
            };
            merge = {
              tool = "nvimdiff";
              conflictstyle = "diff3";
              railsschema = {
                name = "newer Rails schema version";
                driver = ''
                  ruby -e '\n\
                    system %(git), %(merge-file), %(--marker-size=%L), %(%A), %(%O), %(%B)\n\
                    b = File.read(%(%A))\n\
                    b.sub!(/^<+ .*\\nActiveRecord::Schema\\.define.:version => (\\d+). do\\n=+\\nActiveRecord::Schema\\.define.:version => (\\d+). do\\n>+ .*/) do\n\
                    %(ActiveRecord::Schema.define(:version => #{[$1, $2].max}) do)\n\
                    end\n\
                    File.open(%(%A), %(w)) {|f| f.write(b)}\n\
                    exit 1 if b.include?(%(<)*%L)'
                '';
              };
            };
            color = {
              branch = "auto";
              # diff = "auto";
              status = "auto";
              interactive = true;
              ui = true;
              pager = true;
              diff = {
                old = "red strike";
                new = "green italic";
              };
            };
            core = {
              page = "delta --dark --diff-so-fancy";
              whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
              editor = "nvim";
              autocrlf = "input";
            };
            push.default = "current"; # or upstream?
            pull = {
              ff = "only";
              rebase = true;
            };
            branch.autosetuprebase = "always";
            rebase = {
              autosquash = true;
              autostash = true;
              autoStash = true;
            };
            rerere = {
              enabled = true;
              autoupdate = true;
            };
            init.defaultBranch = "main";
            # core.pager = "less -+FRSX -FRX";
            url = {
              "ssh://git@github.com/" = {
                insteadOf = "https://github.com/";
              };
              "ssh://git@gitlab.com/" = {
                insteadOf = "https://gitlab.com/";
              };
              "ssh://git@bitbucket.org/" = {
                insteadOf = "https://bitbucket.org/";
              };
              "ssh://git@code.byted.org/" = {
                insteadOf = "https://code.byted.org/";
              };
            };
          };

          ignores = [
            # Node
            "npm-debug.log"

            # Mac
            ".DS_Store"
            ".DS_Store?"
            "._*"
            ".Spotlight-V100"
            ".Trashes"
            "# Icon?"

            # Windows
            ".Thumbs.db"
            "ehthumbs.db"

            # WebStorm
            ".idea/"

            # vi
            "*~"

            # General
            "log/"
            "*.log"

            "node_modules"
            ".direnv/"
            "*.pyc"
            "*.map"
            ".ignore"
            "*.swp"
          ];
        };

        lazygit = {
          enable = true;
        };
      };
    };
  };
}
