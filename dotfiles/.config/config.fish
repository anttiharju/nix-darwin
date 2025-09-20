# This is slow, hence the if condition.
if not ssh-add -l >/dev/null 2>&1
  ssh-add --apple-load-keychain 2> /dev/null
end

# Disable greeting.
set fish_greeting

# Abbreviations.
abbr -a 's' 'sudo'
abbr -a 'ds' 'sudo darwin-rebuild switch'
abbr -a 'shebang' 'printf "#!/usr/bin/env bash" | pbcopy'
abbr -a 'prune-branches' 'git branch | grep -v "\*\\|  main\$\\|  master\$" | xargs git branch -D'
abbr -a 'gda' 'git reset --hard && git clean -df && git clean -dfx -e "*/.flox/**" -e "collections/**" -e "automation/bin/**" -e "plugins/**"'
abbr -a 'gd' 'git reset --hard && git clean -df'
