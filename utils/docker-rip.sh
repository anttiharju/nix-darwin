#!/usr/bin/env bash
set -e

cleanup() {
    # Check if CONTAINER_ID is set and not empty
    if [ -n "${CONTAINER_ID:-}" ]; then
        echo "Removing container $CONTAINER_ID..."
        docker rm "$CONTAINER_ID" &>/dev/null || true
    fi

    # Check if TMP_DIR is set and not empty
    if [ -n "${TMP_DIR:-}" ] && [ -d "$TMP_DIR" ]; then
        echo "Removing temporary directory $TMP_DIR..."
        rm -rf "$TMP_DIR"
    fi
}

trap cleanup EXIT

# Check if enough arguments are provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 IMAGE_NAME [SRC_DIR] [DEST_DIR]"
    echo "  IMAGE_NAME: Docker image to extract from"
    echo "  SRC_DIR: Directory in the container to extract (default: /)"
    echo "  DEST_DIR: Local directory to extract to (default: .)"
    exit 1
fi

# Parse parameters
IMAGE="$1"
SRC_DIR="${2:-/}"
DEST_DIR="${3:-.}"

# Ensure SRC_DIR always starts with a slash
if [[ "$SRC_DIR" != /* ]]; then
    SRC_DIR="/$SRC_DIR"
fi

mkdir -p "$DEST_DIR"

echo "Creating temporary container from $IMAGE..."
# Add a simple command that does nothing but return success
CONTAINER_ID=$(docker create "$IMAGE" /bin/sh -c "true")

echo "Extracting $SRC_DIR from container to $DEST_DIR..."
# Create a temporary directory for extraction
TMP_DIR=$(mktemp -d)
# First extract everything to temp directory
docker export "$CONTAINER_ID" | tar -x -C "$TMP_DIR"

# Then copy only the requested directory to the destination
if [ -d "$TMP_DIR$SRC_DIR" ]; then
    # For safety, check if there are files to copy
    if [ "$(ls -A "$TMP_DIR$SRC_DIR")" ]; then
        # Safety check to prevent deleting current or parent directory
        if [ "$DEST_DIR" != "." ] && [ "$DEST_DIR" != ".." ]; then
            rm -rf "$DEST_DIR"
            cp -r "$TMP_DIR$SRC_DIR" "$DEST_DIR"
        else
            # For . or .. directories, copy files individually instead of removing first
            cp -r "$TMP_DIR$SRC_DIR"/* "$DEST_DIR"/
        fi
        echo "Contents of $SRC_DIR extracted successfully to $DEST_DIR"
    else
        echo "Warning: Directory $SRC_DIR exists but is empty"
    fi
else
    echo "Error: Directory $SRC_DIR not found in the container"
    echo "Available top-level directories:"
    find "$TMP_DIR" -maxdepth 1 -type d | sed "s|$TMP_DIR||" | grep -v "^$"
    exit 1
fi

echo "Extraction complete!"
