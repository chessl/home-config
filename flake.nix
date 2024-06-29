# As a first step, I will try to symlink my configs as much as possible then
# migrate the configs to Nix
#
# https://nixcloud.io/ for Nix syntax
# https://nix.dev/
# https://nixos.org/guides/nix-pills/
# https://nix-community.github.io/awesome-nix/
# https://discourse.nixos.org/t/home-manager-equivalent-of-apt-upgrade/8424/3
# https://www.reddit.com/r/NixOS/comments/jmom4h/new_neofetch_nixos_logo/gayfal2/
# https://www.youtube.com/user/elitespartan117j27/videos?view=0&sort=da&flow=grid
# https://www.youtube.com/playlist?list=PLRGI9KQ3_HP_OFRG6R-p4iFgMSK1t5BHs
# https://www.reddit.com/r/NixOS/comments/k9xwht/best_resources_for_learning_nixos/
# https://www.reddit.com/r/NixOS/comments/k8zobm/nixos_preferred_packages_flow/
# https://www.reddit.com/r/NixOS/comments/j4k2zz/does_anyone_use_flakes_to_manage_their_entire/
# https://serokell.io/blog/practical-nix-flakes

{
  description = "~ 🍭 ~";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, ... }@inputs:
    let
      sharedHostsConfig = { config, pkgs, ... }: {
        nix = {
          useDaemon = true;
          nixPath = [
            "nixpkgs=${inputs.nixpkgs}"
            "darwin=${inputs.darwin}"
            "home-manager=${inputs.home-manager}"
          ];
          package = pkgs.nixVersions.git;
          extraOptions = "experimental-features = nix-command flakes";
          gc = {
            automatic = true;
            options = "--delete-older-than 3d";
          };

          settings = {
            # disabled, because some buggy behaviour: https://github.com/NixOS/nix/issues/7273
            auto-optimise-store = false;
            substituters = [
              # "https://cache.nixos.org"
              # "https://nix-community.cachix.org"
              # "https://nixpkgs.cachix.org"
              # "https://srid.cachix.org"
              # "https://nix-linter.cachix.org"
              # "https://statix.cachix.org"
              "https://mirror.sjtu.edu.cn/nix-channels/store"
              "https://mirrors.ustc.edu.cn/nix-channels/store"
              "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
            ];
            # binaryCachePublicKeys = [
            #   "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            #   "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            #   "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
            #   "srid.cachix.org-1:MTQ6ksbfz3LBMmjyPh0PLmos+1x+CdtJxA/J2W+PQxI="
            #   "nix-linter.cachix.org-1:BdTne5LEHQfIoJh4RsoVdgvqfObpyHO5L0SCjXFShlE="
            #   "statix.cachix.org-1:Z9E/g1YjCjU117QOOt07OjhljCoRZddiAm4VVESvais="
            # ];
          };
        };

        fonts = {
          packages = with pkgs; [
            fira-code
            jetbrains-mono
            monolisa
            monolisa-nerd
            eb-garamond
            (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
          ];
        };

        nixpkgs = {
          config = {
            allowUnfree = true;
          };
          overlays = [
            self.overlay
          ];
        };

        # time.timeZone = config.my.timezone;

        documentation.man = {
          enable = true;
          # Currently doesn't work in nix-darwin
          # https://discourse.nixos.org/t/man-k-apropos-return-nothing-appropriate/15464
          # generateCaches = true;
        };

        # This value determines the NixOS release from which the default
        # settings for stateful data, like file locations and database versions
        # on your system were taken. It‘s perfectly fine and recommended to leave
        # this value at the release version of the first install of this system.
        # Before changing this value read the documentation for this option
        # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
        # https://nixos.org/manual/nixos/stable/index.html#sec-upgrading
        system.stateVersion = if pkgs.stdenv.isDarwin then 4 else "20.09"; # Did you read the comment?

      };

    in
    {
      overlay = _: prev: {
        monolisa = prev.callPackage ./nix/pkgs/monolisa.nix { };
        monolisa-nerd = prev.callPackage ./nix/pkgs/monolisa-nerd.nix { };
      };

      darwinConfigurations = {
        "lambda-box" = inputs.darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          inherit inputs;
          modules = [
            inputs.home-manager.darwinModules.home-manager
            ./nix/modules/shared
            sharedHostsConfig
            ./nix/hosts/personal.nix
          ];
        };

        "beta-box" = inputs.darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          inherit inputs;
          modules = [
            inputs.home-manager.darwinModules.home-manager
            ./nix/modules/shared
            sharedHostsConfig
            ./nix/hosts/work.nix
          ];
        };
      };

      # for convenience
      # nix build './#darwinConfigurations.pandoras-box.system'
      # vs
      # nix build './#pandoras-box'
      # Move them to `outputs.packages.<system>.name`

      lambda-box = self.darwinConfigurations.lambda-box.system;
      beta-box = self.darwinConfigurations.beta.system;
    };
}
