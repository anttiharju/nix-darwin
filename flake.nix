{
  description = "Example nix-darwin system flake";

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
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          pkgs.vim
          pkgs.git
          pkgs.bat
          pkgs.fish
          pkgs.gh
        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Not everything can be installed through nix.
      system.primaryUser = "antti";
      system.defaults.dock.autohide = true;
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

      # Enable alternative shell support in nix-darwin.
      programs.fish = {
        enable = true;
        interactiveShellInit = (builtins.readFile ./dotfiles/.config/config.fish);
      };

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
      users.knownUsers = [ "antti" ];
      users.users.antti= {
        name = "antti";
        home = "/Users/antti";
        uid = 501;
        shell = pkgs.fish;
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#harju
    darwinConfigurations."harju" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.antti = ./home.nix;

          # Optionally, use home-manager.extraSpecialArgs to pass
          # arguments to home.nix
        }
      ];
    };
  };
}
