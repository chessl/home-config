{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.my.modules.ssh;
  inherit (config.my.user) home;
in
{
  options = {
    my.modules.ssh = {
      enable = mkEnableOption ''
        Whether to enable ssh module
      '';
      includes = mkOption {
        type = with types; listOf str;
        default = [];
        description = ''
          File globs of ssh config files that should be included via the
          `Include` directive.

          See
          {manpage}`ssh_config(5)`
          for more information.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    home-manager.users."${config.my.username}" = {
      programs = {
        ssh = {
          enable = true;
          compression = true;
          # Reuse connections
          controlMaster = "auto";
          controlPath = "~/.ssh/%r@%h:%p.sock";
          controlPersist = "yes";
          inherit (cfg) includes;
        };
      };
    };
  };
}
