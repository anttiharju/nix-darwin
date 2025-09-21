#!/bin/sh
set -eu

# sign-commits:
# Retroactively, for example after deprecating an email address, sign all where both the author and committer match the current git config.

current_email="$(git config user.email)"
current_name="$(git config user.name)"

echo "Signing commits matching: $current_name <$current_email>"
(
    export FILTER_BRANCH_SQUELCH_WARNING=1
    git filter-branch -f --commit-filter "
        if [ \"\$GIT_AUTHOR_EMAIL\" = \"$current_email\" ] && \
        [ \"\$GIT_AUTHOR_NAME\" = \"$current_name\" ] && \
        [ \"\$GIT_COMMITTER_EMAIL\" = \"$current_email\" ] && \
        [ \"\$GIT_COMMITTER_NAME\" = \"$current_name\" ];
        then
            git commit-tree -S \"\$@\";
        else
            git commit-tree \"\$@\";
        fi" HEAD
)
