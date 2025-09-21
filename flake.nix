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
    flox.url = "github:flox/flox/v1.7.3";
  };
  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, flox }:
  let
    configuration = { pkgs, lib, ... }: {
      nixpkgs.hostPlatform = "aarch64-darwin";
      nix.settings.experimental-features = "nix-command flakes";
      nix.settings.substituters = [ "https://cache.flox.dev" ];
      nix.settings.trusted-public-keys = [ "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs=" ];

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;
      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;
      system.defaults.dock.autohide = true;
      system.primaryUser = "antti";

      # Default shell
      environment.systemPackages = [
        flox.packages.aarch64-darwin.default
        pkgs.fish
      ];
      programs.fish = {
        enable = true;
        interactiveShellInit = (builtins.readFile ./dotfiles/config.fish);
      };

      # User config
      users.knownUsers = [ "antti" ];
      users.users.antti = {
        name = "antti";
        home = "/Users/antti";
        uid = 501;
        shell = pkgs.fish;
      };

      # Mac App Store and Homebrew
      homebrew = {
        enable = true;
        masApps = {
          "Strongbox Pro" = 1481853033; # id is from website url
        };
        taps = [
          "nikitabobko/tap" # aerospace
        ];
        # Managing GUI applications through Nix on darwin is akward (not indexed by Spotlight)
        casks = [
          "visual-studio-code"
          "aerospace"
          "orbstack"
          "ghostty"
        ];
      };

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
