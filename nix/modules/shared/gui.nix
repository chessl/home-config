{ pkgs, lib, config, options, ... }:

let

  cfg = config.my.modules.gui;

in
{
  options = with lib; {
    my.modules.gui = {
      enable = mkEnableOption ''
        Whether to enable gui module
      '';
    };
  };

  config = with lib;
    mkIf cfg.enable (mkMerge [
      (if (builtins.hasAttr "homebrew" options) then {
        # TODO: (automate) Requires homebrew to be installed
        homebrew.taps = [
          # "homebrew/cask"
          # "homebrew/cask-versions"
          # "riscv/riscv"
        ];
        homebrew.casks = [
          # "surge"
          "iina"
          "sublime-text"
          "raycast"
          "microsoft-edge"
          "keka"
          "kekaexternalhelper"
          "orbstack"
        ];

      } else {
        my.user = {
          packages = with pkgs; [
            anki
          ];
        };
      })
    ]);
}
