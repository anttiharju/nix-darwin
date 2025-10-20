#!/usr/bin/env bash
set -euo pipefail

# Check if this is likely a commit message (temporary file in .git or contains COMMIT_EDITMSG)
if [[ "$1" == *"COMMIT_EDITMSG"* ]] || [[ "$1" == *".git/"*"COMMIT_EDITMSG" ]]; then
    vim +startinsert "$@"
else
    vim "$@"
fi
