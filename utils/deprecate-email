#!/bin/sh
set -eu

# deprecate-email:
# Sometimes I remove email addresses from my GitHub profile. This makes the contributions in my profile disappear as the email address is no longer associated with my account. This script replaces commits with input email with current git config.

if [ -z "$1" ]; then
    echo "Error: old_email argument is required."
    exit 1
fi

old_email="$1"
new_email="$(git config user.email)"
new_name="$(git config user.name)"

# Replacing author and committer emails has to be done separately to avoid unintentional overwrites
# e.g. in commits with multiple authors.
(
    export FILTER_BRANCH_SQUELCH_WARNING=1
    echo "1/2 Overwriting committer"
    git filter-branch -f --commit-filter "
        if [ \"\$GIT_COMMITTER_EMAIL\" = \"$old_email\" ] || \
        ([ \"\$GIT_COMMITTER_EMAIL\" = \"noreply@github.com\" ] && \
            ([ \"\$GIT_AUTHOR_EMAIL\" = \"$old_email\" ] || \
            [ \"\$GIT_AUTHOR_EMAIL\" = \"$new_email\" ]));
        then
            GIT_COMMITTER_NAME=\"$new_name\";
            GIT_COMMITTER_EMAIL=\"$new_email\";
            git commit-tree \"\$@\";
        else
            git commit-tree \"\$@\";
        fi" HEAD
    echo "2/2 Overwriting author"
    git filter-branch -f --commit-filter "
        if [ \"\$GIT_AUTHOR_EMAIL\" = \"$old_email\" ];
        then
            GIT_AUTHOR_NAME=\"$new_name\";
            GIT_AUTHOR_EMAIL=\"$new_email\";
            git commit-tree \"\$@\";
        else
            git commit-tree \"\$@\";
        fi" HEAD
)
