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
    };
    packages = [
      pkgs.aerospace
    ];
  };
  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      extraConfig = {
        push = { autoSetupRemote = true; };
        core = {
          editor = "vim";
          sshCommand = "ssh -F ~/.ssh/config";
          excludesFile = "~/.gitignore";
        };
      };
      userEmail = "antti@harju.io";
      userName = "anttiharju";
    };
  };
}
