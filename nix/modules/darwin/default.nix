{ config, pkgs, ... }:

{
  nix.configureBuildUsers = true;

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.cleanup = "zap";
    onActivation.upgrade = true;
    global.brewfile = true;
    global.lockfiles = true;
    # brewPrefix = "/opt/homebrew/bin";
  };

  imports = [
    # ./applications.nix
    ./macos.nix
    ./wm.nix
  ];
}
