{ config, pkgs, lib, inputs, ... }: {
  imports = [ ../modules/darwin ];

  nix = {
    gc = { user = config.my.username; };
  };

  services.nix-daemon.enable = true;

  my = {
    modules = {
      gpg.enable = true;
      wm.enable = true;
      macos.enable = true;
      git = {
        enable = true;
        username = "chess";
        includes = [
          {
            path = "~/.gitconfig.local";
          }
        ];
      };
      ssh = {
        enable = true;
        includes = [
          "~/.ssh/config.local"
        ];
      };
    };
  };

  homebrew.brews = [ ];
  homebrew.casks = [
    "wechat"
    "telegram"
    "discord"
    "kindle"
  ];

  networking = {
    hostName = "lambda-box";
    computerName = "lambda-box";
    knownNetworkServices = [
      "Wi-Fi"
      "Ethernet Adaptor"
      "Thunderbolt Ethernet"
    ];
    dns = [
      "8.8.8.8"
      "8.8.4.4"
      "2001:4860:4860::8888"
      "2001:4860:4860::8888"
    ];
  };
}
