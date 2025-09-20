#!/bin/sh
set -eu

# Git CLONE:
# Clone a repo via SSH based on https URL or just the repo name.

# Check if input argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $(basename "$0") <repo https URL or name>"
    exit 1
fi
REPO=$1

# If URL was provided, convert to SSH and clone
if echo "$REPO" | grep -qE '^https://'; then
    SSH_URL=$(echo "$REPO" | sed -E 's|https://([^/]+)/([^/]+)/(.+)|git@\1:\2/\3|')
    # Clone the repository using the SSH URL
    git clone "$SSH_URL"
    exit 0
fi

# From now on assuming $REPO is just the repo name.
# ex.: for "https://github.com/owner/repo" $REPO is "repo").
# Owner can be user or org.

CACHE_FILE=~/.scripts/gclone.cache
# Fetch user from git config and user's orgs from gh api through gh cli.
if [ ! -f "$CACHE_FILE" ]; then
    mkdir -p "$(dirname "$CACHE_FILE")"

    # Optimistic
    echo_user_and_orgs() {
        gh api user --jq .login

        # Fetch the organizations the user is part of using gh CLI
        ORGS=$(gh api user/orgs --jq '.[].login')
        if [ -n "$ORGS" ]; then
            echo "$ORGS"
        fi
    }

    OUTPUT=$(echo_user_and_orgs)
    echo "$OUTPUT" > "$CACHE_FILE"
    echo "Cached the following user and orgs at $CACHE_FILE:"
    echo "$OUTPUT"
fi

# Read the cache file into an array.
possible_owners=""
while IFS= read -r line; do
    possible_owners="$possible_owners $line"
done < "$CACHE_FILE"

repo_exists() {
    owner=$1
    repo=$2
    response=$(gh api -H "Accept: application/vnd.github.v3+json" "/repos/$owner/$repo" --silent --include 2>/dev/null | head -n 1 | awk '{print $2}')
    [ "$response" -eq 200 ]
}

# Check if $REPO exists from each possible owner and clone it once found. Starts from the user.
for owner in $possible_owners; do
    SSH_URL="git@github.com:$owner/$REPO.git"
    if repo_exists "$owner" "$REPO"; then
        echo "Cloning from '$owner'..."
        git clone "$SSH_URL"
        exit 0
    fi
done

echo "Failed to clone '$REPO' from any of the possible owners:"
echo "$possible_owners"
exit 1
