{ config, pkgs, ... }: {
  home.username = "antti";
  home.homeDirectory = "/Users/antti";
  home.stateVersion = "25.05";
  home.file.".hushlogin" = {
    source = ./.hushlogin;
  };
  programs.home-manager.enable = true;
}
