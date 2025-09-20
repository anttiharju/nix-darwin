{ config, pkgs, ... }: {
  home = {
    username = "antti";
    homeDirectory = "/Users/antti";
    stateVersion = "25.05";
    file = {
      ".hushlogin" = {
        source = ./.hushlogin;
      };
      ".aerospace.toml" = {
        source = ./.aerospace.toml;
      };
      ".gitignore" = {
        source = ./.global.gitignore;
      };
      ".gitconfig" = {
        source = ./.gitconfig;
      };
    };
    packages = [
      pkgs.aerospace
    ];
  };
  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      includes = [ { path = "~/.gitconfig"; } ];
    };
  };
}
