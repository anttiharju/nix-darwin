# This is slow, hence the if condition.
if not ssh-add -l >/dev/null 2>&1
  ssh-add --apple-load-keychain 2> /dev/null
end

# Disable greeting.
set fish_greeting

# Abbreviations.
abbr -a "s" "sudo"
abbr -a "ds" "sudo darwin-rebuild switch"
