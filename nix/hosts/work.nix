{ config, pkgs, lib, inputs, ... }: {
  imports = [ ../modules/darwin ];

  nix = { gc = { user = config.my.username; }; };

  services.nix-daemon.enable = true;

  my = {
    username = "bytedance";
    name = "Chess Luo";
    email = "chess@bytedance.com";
    modules = {
      gpg.enable = true;
      wm.enable = true;
      macos.enable = true;
      git = {
        enable = true;
        username = "chess";
        includes = [{
          path = "~/.gitconfig.byted";
          condition = "gitdir:~/Developer/code.byted.org/";
        }];
      };
      ssh = {
        enable = true;
        includes = [ "~/.ssh/config.byted" ];
      };
    };

    user = { packages = with pkgs; [ krb5 ]; };
  };

  homebrew.casks = [ "visual-studio-code" ];

  networking = {
    hostName = "beta-box";
    computerName = "beta-box";
    knownNetworkServices =
      [ "Wi-Fi" "Ethernet Adaptor" "Thunderbolt Ethernet" ];
    # dns = [
    #   "223.5.5.5"
    #   "223.6.6.6"
    #   "2400:3200::1"
    #   "2400:3200:baba::1"
    # ];
  };
}
