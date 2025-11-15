if not set -q TMUX; or test "$TERM_PROGRAM" = "vscode"
  exec tmux
end

# Util for returning to initial directory
set -gx ANTTIHARJU_OG (pwd)
function og
  cd $ANTTIHARJU_OG
end

# Extend path
set -gx PATH ~/.local/bin $PATH
set -gx PATH ~/.vmatch/bin $PATH
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

# Misc. abbreviations
abbr -a 'ma' 'make'
abbr -a 'shebang' 'printf "#!/usr/bin/env bash" | pbcopy'
abbr -a 'prune-branches' 'git branch | grep -v "\*\\|  main\$\\|  master\$" | xargs git branch -D'
abbr -a 'cr' 'cargo run'

# Git abbreviations
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
abbr -a 'gsm' 'git switch main || git switch master'
abbr -a 'gs-' 'git switch -'
abbr -a 'grm' 'git rebase main || git rebase master'
abbr -a 'gpf' 'git push --force'
abbr -a 'gps' 'git push'
abbr -a 'gt' 'git tag --sort=-creatordate'
abbr -a 'allow-push' 'git config --local "branch.$(git branch --show-current).pushRemote" origin'

function up-or-search -d "Depending on cursor position and current mode, either search backward or move up one line"
  # If we are already in search mode, continue
  if commandline --search-mode
    commandline -f history-search-backward
    return
  end

  # If we are navigating the pager, then up always navigates
  if commandline --paging-mode
    commandline -f up-line
    return
  end

  # We are not already in search mode.
  # If we are on the top line, start search mode,
  # otherwise move up
  set lineno (commandline -L)

  switch $lineno
    case 1
      history merge
      commandline -f history-search-backward

    case '*'
      commandline -f up-line
  end
end
