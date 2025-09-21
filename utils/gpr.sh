#!/bin/sh
set -eu

# Git PR:
# open the existing or a new PR for current branch. On default branch opens the repo.

# Determine default branch.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    default_branch=$(git rev-parse --abbrev-ref origin/HEAD)
    default_branch=${default_branch#"origin/"}
else
    echo "Error: gpr must be run in a Git repository."
    exit 1
fi

# Get origin URL and ensure it's in GitHub.
origin=$(git remote get-url origin)
case "$origin" in
    *github.com*)
        ;;
    *)
        echo "Error: gpr requires origin url in GitHub."
        exit 1
        ;;
esac

# Extract the repository URL in a format that can be opened in a browser.
if echo "$origin" | grep -q 'git@github.com:'; then
    repo_url="https://github.com/$(echo "$origin" | sed 's/^.*github.com://;s/.git$//')"
elif echo "$origin" | grep -q 'https://github.com/'; then
    repo_url=$(echo "$origin" | sed 's/.git$//')
else
    echo "Error: gpr only supports ssh and https-cloned repos."
    exit 1
fi

# Get current branch name.
branch=$(git rev-parse --abbrev-ref HEAD)

# Open the repo on default branch.
if [ "$branch" = "$default_branch" ]; then
    open "$repo_url"
    exit $?
fi

owner=$(echo "$repo_url" | cut -d'/' -f4)
repo=$(echo "$repo_url" | cut -d'/' -f5)

pr_url=$(gh api "repos/$owner/$repo/pulls?head=$owner:$branch" --jq '.[0].html_url')

if [ -z "$pr_url" ]; then
    # TODO: push branch if it hasn't been pushed to remote.
    open "$repo_url/pull/$branch"
    exit 0
fi

# Get urls of open Safari tabs via AppleScript.
urls=$(osascript << 'EOA'
tell application "Safari"
    set windowList to every window
    set urlList to {}
    repeat with aWindow in windowList
        set tabList to every tab in aWindow
        repeat with aTab in tabList
            set end of urlList to URL of aTab
        end repeat
    end repeat
    return urlList
end tell
EOA
)
IFS=', ' # Convert the output to a list

for url in $urls; do
    if echo "$url" | grep -q "$pr_url"; then
        open "$url"
        exit 0
    fi
done

# Otherwise fall back to old behavior.
open "$pr_url"
