{ pkgs, lib, config, options, ... }:

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
    mkIf cfg.enable (mkMerge [
      (if (builtins.hasAttr "homebrew" options) then {
        # TODO: (automate) Requires homebrew to be installed
        homebrew.taps = [
          "nikitabobko/tap"
        ];
        homebrew.casks = [
          "nikitabobko/tap/aerospace"
        ];

      } else {
        my.user = { };
      })

      {
        my.hm.file = {
          ".config/aerospace/aerospace.toml" = {
            source = ../../../config/aerospace.toml;
          };
        };
      }
    ]);
}
