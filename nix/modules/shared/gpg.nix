{ pkgs, lib, config, ... }:

let

  cfg = config.my.modules.gpg;
  inherit (config.my) hm;

in
{
  options = with lib; {
    my.modules.gpg = {
      enable = mkEnableOption ''
        Whether to enable gpg module
      '';
    };
  };

  config = with lib;
    mkIf cfg.enable {
    #   environment.systemPackages = with pkgs; [ gnupg ];
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };

      my.env = {
        # GNUPGHOME = "$XDG_CONFIG_HOME/gnupg";
        GPG_TTY = "$(tty)";
      };

    #   my.user = {
    #     packages = with pkgs;
    #       [
    #         keybase
    #         # keybase-gui # ???
    #       ];
    #   };


      home-manager.users."${config.my.username}" = {

        programs.gpg = {
          enable = true;
          # homeDir = "${hm.configHome}/gnupg";
          # homeDir = "${hm.config.xdg.configHome}/gnupg";
          settings = {
            # use gpg agent if available
            use-agent = true;
            # Don't disclose the version
            no-emit-version = true;
            # Don't add additional comments
            no-comments = true;
            # We want to force UTF-8 everywhere
            display-charset = "utf-8";
            # when outputting certificates, view user IDs distinctly from keys:
            fixed-list-mode = true;
            # long keyids are more collision-resistant than short keyids (it's trivial to make a key with any desired short keyid)
            keyid-format = "0xlong";
            # all keys please with fingerprints
            with-fingerprint = true;
            # You should always know at a glance which User IDs gpg thinks are legitimately bound to the keys in your keyring:
            verify-options = "show-uid-validity";
            list-options = "show-uid-validity";
            # BEGIN Some suggestions from Debian http://keyring.debian.org/creating-key.html
            personal-digest-preferences = "SHA512";
            cert-digest-algo = "SHA512";
            default-preference-list = "SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed";

            # Some suggestions added from riseup https://we.riseup.net/riseuplabs+paow/openpgp-best-practices
            ## When creating a key, individuals may designate a specific keyserver to use to pull their keys from.
            ## The above option will disregard this designation and use the pool, which is useful because (1) it
            ## prevents someone from designating an insecure method for pulling their key and (2) if the server
            ## designated uses hkps, the refresh will fail because the ca-cert will not match, so the keys will
            ## never be refreshed.
            keyserver-options = "no-honor-keyserver-url";

            # include an unambiguous indicator of which key made a signature:
            # (see http://thread.gmane.org/gmane.mail.notmuch.general/3721/focus=7234)
            sig-notation = "issuer-fpr@notations.openpgp.fifthhorseman.net=%g";
          };
        };

        # services.gpg-agent = {
        #   enable = true;
        #   enableBashIntegration = true;
        #   enableFishIntegration = true;
        #   enableZshIntegration = true;
        #   enableExtraSocket = true;
        #   enableSshSupport = true;
        #   # Default: 600 seconds
        #   defaultCacheTtl = 86400;
        #   maxCacheTtl = 86400;
        #
        #   # Default: 600 seconds
        #   defaultCacheTtlSsh = 86400;
        #   maxCacheTtlSsh = 86400;
        #   extraConfig = ''
        #     allow-preset-passphrase
        #   '';
        # };

        #   programs.git.signing = "";
        #   programs.git.signing.signByDefault = true;

        #   my.hm.file = {
        #     ".config/gnupg/gpg-agent.conf".text = ''
        #       default-cache-ttl 600
        #       max-cache-ttl 7200'';

        #     ".config/gnupg/gpg.conf" = {
        #       text = ''
        #         # ${config.my.nix_managed}
        #         ${builtins.readFile ../../../config/gnupg/gpg.conf}'';
        #     };
        #   };
      };
    };
}
