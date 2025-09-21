if not set -q TMUX
  exec tmux
end

# Extend path
set -gx PATH ~/.local/bin $PATH
eval "$(/opt/homebrew/bin/brew shellenv)"

# This is slow, hence the if condition.
if not ssh-add -l >/dev/null 2>&1
  ssh-add --apple-load-keychain 2> /dev/null
end

# Disable greeting.
set fish_greeting

# Aliases
alias "cat=bat --plain"
alias "tree=tree --dirsfirst"

# Abbreviations.
abbr -a 's' 'sudo'
abbr -a 'shebang' 'printf "#!/usr/bin/env bash" | pbcopy'
abbr -a 'prune-branches' 'git branch | grep -v "\*\\|  main\$\\|  master\$" | xargs git branch -D'
abbr -a 'gda' 'git reset --hard && git clean -df && git clean -dfx -e "*/.flox/**" -e "collections/**" -e "automation/bin/**" -e "plugins/**"'
abbr -a 'gd' 'git reset --hard && git clean -df'
abbr -a 'gs' 'git status'
abbr -a 'allow-push' 'git config --local "branch.$(git branch --show-current).pushRemote" origin'
