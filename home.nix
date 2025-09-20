{ config, pkgs, ... }: {
  home = {
    username = "antti";
    homeDirectory = "/Users/antti";
    stateVersion = "25.05";
    file = {
      ".config/ghostty/config" = { source = ./dotfiles/ghostty; };
      ".aerospace.toml" = { source = ./dotfiles/aerospace.toml; };
      ".gitignore" = { source = ./dotfiles/gitignore; };
      ".gitconfig" = { source = ./dotfiles/gitconfig; };
      ".hushlogin" = { source = ./dotfiles/hushlogin; };
      ".local/bin" = {
        source = ./utils;
        recursive = true;
        executable = true;
      };
    };
    packages = [
      pkgs.aerospace
      pkgs.vscode
      pkgs.tree
      pkgs.bat
      pkgs.git
      pkgs.vim
      pkgs.gh
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
