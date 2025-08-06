#!/bin/bash

# --- Configuration ---
COMPOSE_PROJECT_NAME=$(basename $(pwd))
VOLUME_NAME="${COMPOSE_PROJECT_NAME}_cache-data"

# --- Script Logic ---
echo "--- Starting Cache Purge (Old Directories) ---"

VOLUME_PATH=$(docker volume inspect -f '{{ .Mountpoint }}' "$VOLUME_NAME")
if [ -z "$VOLUME_PATH" ]; then
  echo "Error: Could not find mount point for volume '$VOLUME_NAME'."
  exit 1
fi

# The name of the symlink that points to the currently active cache (matches nginx config)
ACTIVE_SYMLINK_NAME="kiwix"

# Get the name of the currently active cache directory
ACTIVE_CACHE_DIR_NAME=$(readlink -f "$VOLUME_PATH/$ACTIVE_SYMLINK_NAME")
echo "Currently active cache directory: $ACTIVE_CACHE_DIR_NAME"

# Find all directories in the volume that are NOT the currently active one
echo "Searching for old cache directories to purge..."
for dir in $(find "$VOLUME_PATH" -maxdepth 1 -type d -name "kiwix_cache_*" ! -path "$ACTIVE_CACHE_DIR_NAME"); do
  if [ -d "$dir" ]; then
    echo "Found old cache directory: $dir"
    read -p "Do you want to remove it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "Removing '$dir'..."
      sudo rm -rf "$dir"
      echo "Removed '$dir'."
    else
      echo "Skipped '$dir'."
    fi
  fi
done

echo "--- Cache Purge Complete ---"
