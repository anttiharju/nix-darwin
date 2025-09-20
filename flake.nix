{
  description = "Antti's MacBook Pro config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    configuration = { pkgs, lib, ... }: {
      environment.systemPackages = [ pkgs.fish ];
      programs.fish = {
        enable = true;
        interactiveShellInit = (builtins.readFile ./dotfiles/config.fish);
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";
      system.defaults.dock.autohide = true;

      # Not everything can be installed through nix.
      homebrew = {
        enable = true;
        masApps = {
          "Strongbox Pro" = 1481853033;
        };
        casks = [
          "ghostty"
          "orbstack"
        ];
      };

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;
      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      system.primaryUser = "antti";
      users.knownUsers = [ "antti" ];
      users.users.antti = {
        name = "antti";
        home = "/Users/antti";
        uid = 501;
        shell = pkgs.fish;
      };

      nixpkgs.hostPlatform = "aarch64-darwin";
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "vscode"
      ];
    };
  in
  {
    darwinConfigurations."harju" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.antti = ./home.nix;
        }
      ];
    };
  };
}

