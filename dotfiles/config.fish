if not set -q TMUX; or test "$TERM_PROGRAM" = "vscode"
  exec tmux
end

# Extend path
set -gx PATH ~/.local/bin $PATH
eval "$(/opt/homebrew/bin/brew shellenv)"

# This is slow hence the if condition
if not ssh-add -l >/dev/null 2>&1
  ssh-add --apple-load-keychain 2> /dev/null
end

# Disable greeting
set fish_greeting

# Aliases
alias "cat=bat --plain"
alias "tree=tree --dirsfirst"

# Abbreviations
abbr -a 's' 'sudo'
abbr -a 'ma' 'make'
abbr -a 'shebang' 'printf "#!/usr/bin/env bash" | pbcopy'
abbr -a 'prune-branches' 'git branch | grep -v "\*\\|  main\$\\|  master\$" | xargs git branch -D'
abbr -a 'gd' 'git diff'
abbr -a 'gds' 'git diff --staged'
abbr -a 'gra' 'git reset --hard && git clean -df && git clean -dfx -e "*/.flox/**" -e "collections/**" -e "automation/bin/**" -e "plugins/**"'
abbr -a 'gr' 'git reset --hard && git clean -df'
abbr -a 'gs' 'git status'
abbr -a 'gaa' 'git add --all'
abbr -a 'gc' 'git commit'
abbr -a 'gca' 'git commit --amend'
abbr -a 'gcae' 'git commit --amend --no-edit'
abbr -a 'gpp' 'git push && gpr'
abbr -a 'gp' 'git pull'
abbr -a 'gsc' 'git switch -c'
abbr -a 'allow-push' 'git config --local "branch.$(git branch --show-current).pushRemote" origin'
