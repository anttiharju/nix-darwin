{ config, pkgs, pkgs-unstable, ... }: {
  home = {
    username = "antti";
    homeDirectory = "/Users/antti";
    stateVersion = "25.05";
    file = {
      "Library/LaunchAgents/com.local.KeyRemapping.plist" = { source = ./dotfiles/com.local.KeyRemapping.plist; };
      ".config/direnv/direnv.toml" = { source = ./dotfiles/direnv.toml; };
      ".config/ghostty/config" = { source = ./dotfiles/ghostty.conf; };
      ".aerospace.toml" = { source = ./dotfiles/aerospace.toml; };
      ".gitignore" = { source = ./dotfiles/gitignore; };
      ".gitconfig" = { source = ./dotfiles/gitconfig; };
      ".hushlogin" = { source = ./dotfiles/hushlogin; };
      ".local/bin" = {
        source = pkgs.runCommandNoCC "bin-scripts" {} ''
          mkdir -p $out
          for file in ${./utils}/*; do
            if [ -f "$file" ]; then
              filename=$(basename "$file")
              name=''${filename%.*}
              ln -s "/etc/nix-darwin/utils/$filename" "$out/$name"
            fi
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
    packages = with pkgs; [
      tree
      bat
      gh
      yq
      yamlfmt
      ruff
      pkgs-unstable.prettier
      uv
      mtr
      mkdocs
      actionlint
      action-validator
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
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
