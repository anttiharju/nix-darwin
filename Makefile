default:
	sudo darwin-rebuild switch
	tmux source-file /etc/nix-darwin/dotfiles/tmux.conf

bootstrap:
	sudo nix run nix-darwin/nix-darwin-25.05#darwin-rebuild -- switch

brew:
	brew update
	brew upgrade
	brew list --casks | xargs brew upgrade
	brew cleanup --prune=all

gc:
	nix-store --gc
