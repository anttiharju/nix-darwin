default:
	sudo darwin-rebuild switch
	tmux source-file /etc/nix-darwin/dotfiles/tmux.conf

bootstrap:
	sudo nix run nix-darwin/nix-darwin-25.05#darwin-rebuild -- switch