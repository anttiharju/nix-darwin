#!/bin/sh
set -eu

# Git Log:
# sensible defaults based on context. Alternatively print N commits 'gl 5'.

# Determine default branch
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    default_branch=$(git rev-parse --abbrev-ref origin/HEAD)
    default_branch=$(echo "$default_branch" | sed 's|^origin/||')
else
    echo "Error: gl must be run in a Git repository."
    exit 1
fi

# Determine current branch
branch=$(git rev-parse --abbrev-ref HEAD)

git_cmd="git log --oneline" # base git log command

# Reverse print order if on a branch other than the default one.
match_ui() {
    if [ "$branch" != "$default_branch" ]; then
        git_cmd="$git_cmd --reverse"
    fi
}

# Execute the git command and exit with its status.
execute() {
    match_ui # always match UI order.
    eval "$git_cmd"
    exit $?
}

# Set n to empty string if $1 is unbound.
n="${1:-}"

# Show N commits if provided as a parameter. Should take precedence over everything else.
if [ -n "$n" ]; then
    git_cmd="$git_cmd -$n"
    execute
fi

# Limit number of printed commits to prevent scrolling in terminal.
no_scroll() {
    terminal_height=$(($(tput lines) - 2)) # Deduct 2 (1 for cmd, 1 for prompt).
    line_count=$(eval "$git_cmd | wc -l") # Count how many commits would be printed.

    if [ "$line_count" -gt "$terminal_height" ]; then
        git_cmd="$git_cmd -$terminal_height"
    fi
}

# Show all commits on default branch.
if [ "$branch" = "$default_branch" ]; then
    no_scroll # Or however many fit in the terminal.
    execute
fi

# Compare to default branch on other branches.
git_cmd="$git_cmd $default_branch.."
no_scroll
execute
