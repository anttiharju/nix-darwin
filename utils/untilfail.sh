#!/bin/sh

# UNTILFAIL:
# Run command in loop until it fails

count=0
# call commands in "" if you want to use &&
while sh -c "$@"; do
    count=$((count + 1))
done
echo "Succeeded $count times before failing"
