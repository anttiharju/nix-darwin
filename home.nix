{ config, pkgs, ... }: {
  home = {
    username = "antti";
    homeDirectory = "/Users/antti";
    stateVersion = "25.05";
    file.".hushlogin" = {
      source = ./.hushlogin;
    };
  };
  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      extraConfig = {
        push = { autoSetupRemote = true; };
        core = { editor = "vim"; };
      };
      userEmail = "antti@harju.io";
      userName = "anttiharju";
    };
  };
}
