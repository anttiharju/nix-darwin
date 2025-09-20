{ config, pkgs, ... }: {
  home.username = "antti";
  home.homeDirectory = "/Users/antti";
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
