{
  description = "Antti's MacBook Pro config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flox.url = "github:flox/flox/v1.7.3";
  };
  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, nix-darwin, home-manager, flox }:
  let
    system = "aarch64-darwin";
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

    # Base configuration shared by all hosts
    mkConfiguration = { hostname, uid }: { pkgs, lib, ... }: {
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
      networking.hostName = hostname;

      # Default shell
      environment.systemPackages = [
        flox.packages.aarch64-darwin.default
      ];

      programs.fish = {
        enable = true;
      };

      # User config
      users.knownUsers = [ "antti" ];
      users.users.antti = {
        name = "antti";
        home = "/Users/antti";
        uid = uid;
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
        brews = [
          "chrome-cli"
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

    # Common home-manager module
    homeManagerCommonModule = {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.antti = import ./home.nix;
        extraSpecialArgs = {
          inherit pkgs-unstable;
        };
      };
    };
  in
  {
    # Define configurations for both hostnames with their specific UIDs
    darwinConfigurations."harju" = nix-darwin.lib.darwinSystem {
      modules = [
        (mkConfiguration { hostname = "harju"; uid = 501; })
        home-manager.darwinModules.home-manager
        homeManagerCommonModule
      ];
    };
    darwinConfigurations."harju-work" = nix-darwin.lib.darwinSystem {
      modules = [
        (mkConfiguration { hostname = "harju-work"; uid = 504; })
        home-manager.darwinModules.home-manager
        homeManagerCommonModule
      ];
    };
  };
}
