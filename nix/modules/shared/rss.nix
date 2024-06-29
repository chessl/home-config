{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.my.modules.rss;
  inherit (config.my.user) home;
in
{
  options = {
    my.modules.rss = {
      enable = mkEnableOption ''
        Whether to enable rss module
      '';
    };
  };

  config = mkIf cfg.enable {
    home-manager.users."${config.my.username}" = {
      programs = {
        newsboat = {
          enable = true;
          autoReload = true;
          urls = [
            {
              tags = [ ];
              url = "";

            }
          ];
        };
      };
    };
  };
}
