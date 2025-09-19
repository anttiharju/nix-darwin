{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
    let
      configuration = { pkgs, lib, ... }: {
        # Allow only google-chrome as unfree package
        nixpkgs.config.allowUnfreePredicate = pkg:
          builtins.elem (lib.getName pkg) [ "google-chrome" ];

        # List packages installed in system profile.
        environment.systemPackages = [
          pkgs.vim
          pkgs.fish
          pkgs.keepassxc
          pkgs.google-chrome
          pkgs.bat
          pkgs.git
        ];

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        system.stateVersion = 6;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#MacBook-Pro-van-Antti
      darwinConfigurations."MacBook-Pro-van-Antti" = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
      };
    };
}

