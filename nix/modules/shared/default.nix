{ config, lib, pkgs, ... }:

{
  imports = [
    ./settings.nix
    ./shell.nix
    ./gpg.nix
    ./ssh.nix
    ./git.nix
    ./kitty.nix
    ./tmux.nix
    ./vim
    ./node.nix
    ./gui.nix
    ./python.nix
    ./syncthing.nix
    ./rss.nix
  ];

  my.modules = {
    shell.enable = lib.mkDefault true;
    git.enable = lib.mkDefault true;
    ssh.enable = lib.mkDefault true;
    kitty.enable = lib.mkDefault true;
    python.enable = lib.mkDefault true;
    tmux.enable = lib.mkDefault true;
    vim.enable = lib.mkDefault true;
    gui.enable = lib.mkDefault true;
    node.enable = lib.mkDefault true;
    rss.enable = lib.mkDefault true;
  };

  my.hm.file.".editorconfig".source = ../../../config/editorconfig.conf;

}
