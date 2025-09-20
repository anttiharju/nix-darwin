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
      userEmail = "antti@harju.io";
      userName = "anttiharju";
    };
  };
}
