#!/usr/bin/env bash
set -euo pipefail

# Git PR Chrome:
# Use chrome-cli to easily access GitHub PRs in Google Chrome without polluting tabs

ids=()
urls=()
while read -r line; do
    id=$(echo "$line" | awk -F'[][]' '{print $2}')
    url=$(echo "$line" | awk '{print $2}')
    ids+=("$id")
    urls+=("$url")
done < <(chrome-cli list links | grep 'github.com')

# Nothing to work with
if [ ${#ids[@]} -eq 0 ] || [ ${#urls[@]} -eq 0 ]; then
    exit 1
fi

printf "%s\n" "${ids[@]}"
printf "%s\n" "${urls[@]}"
