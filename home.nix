{ config, pkgs, ... }: {
  home = {
    username = "antti";
    homeDirectory = "/Users/antti";
    stateVersion = "25.05";
    file = {
      "Library/LaunchAgents/com.local.KeyRemapping.plist" = { source = ./dotfiles/com.local.KeyRemapping.plist; };
      ".config/ghostty/config" = { source = ./dotfiles/ghostty.conf; };
      ".aerospace.toml" = { source = ./dotfiles/aerospace.toml; };
      ".gitignore" = { source = ./dotfiles/gitignore; };
      ".gitconfig" = { source = ./dotfiles/gitconfig; };
      ".hushlogin" = { source = ./dotfiles/hushlogin; };
      ".local/bin" = {
        source = pkgs.runCommandNoCC "bin-scripts" {} ''
          mkdir -p $out
          for file in ${./utils}/*.sh; do
            name=$(basename "$file" .sh)
            ln -s "$file" "$out/$name"
          done
        '';
        recursive = true;
        executable = true;
      };
      "Library/Application Support/Code/User/keybindings.json" = {
        source = ./dotfiles/vscode/keybindings.jsonc;
        force = true;
      };
      "Library/Application Support/Code/User/settings.json" = {
        source = ./dotfiles/vscode/settings.jsonc;
        force = true;
      };
    };
    packages = [
      pkgs.tree
      pkgs.bat
      pkgs.gh
    ];
  };
  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      includes = [ { path = "~/.gitconfig"; } ];
    };
    tmux = {
      enable = true;
      extraConfig = (builtins.readFile ./dotfiles/tmux.conf);
    };
    vim = {
      enable = true;
      defaultEditor = true;
      settings = {
        number = true;
      };
    };
    fish = {
      enable = true;
      interactiveShellInit = (builtins.readFile ./dotfiles/config.fish);
    };
  };
}
