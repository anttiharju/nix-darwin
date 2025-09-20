{ config, pkgs, ... }: {
  home = {
    username = "antti";
    homeDirectory = "/Users/antti";
    stateVersion = "25.05";
    file = {
      ".hushlogin" = { source = ./dotfiles/.hushlogin; };
      ".aerospace.toml" = { source = ./dotfiles/.aerospace.toml; };
      ".gitignore" = { source = ./dotfiles/.global.gitignore; };
      ".gitconfig" = { source = ./dotfiles/.gitconfig; };
      ".local/bin" = {
        source = ./utils;
        recursive = true;
        executable = true;
      };
    };
    packages = [
      pkgs.vim
      pkgs.git
      pkgs.bat
      pkgs.aerospace
      pkgs.gh
      pkgs.tree
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
