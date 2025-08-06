#!/bin/bash
# rotate_cache.sh 

# --- Configuration ---
COMPOSE_PROJECT_NAME=$(basename $(pwd))
VOLUME_NAME="${COMPOSE_PROJECT_NAME}_cache-data"
NGINX_CONTAINER_NAME="kiwix-nginx-cache"

# --- Script Logic ---
echo "--- Starting Atomic Cache Rotation ---"

VOLUME_PATH=$(docker volume inspect -f '{{ .Mountpoint }}' "$VOLUME_NAME")
if [ -z "$VOLUME_PATH" ]; then
  echo "Error: Could not find mount point for volume '$VOLUME_NAME'."
  exit 1
fi

# The path to the symbolic link inside the volume (matches nginx config)
CACHE_SYMLINK_PATH="$VOLUME_PATH/kiwix"

# 1. Create a new, versioned cache directory on the host
# This new directory is initially empty.
NEW_CACHE_DIR_NAME="kiwix_cache_$(date +%s)"
NEW_CACHE_DIR_PATH="$VOLUME_PATH/$NEW_CACHE_DIR_NAME"
sudo mkdir -p "$NEW_CACHE_DIR_PATH"
echo "Created new, empty cache directory: $NEW_CACHE_DIR_PATH"

# 2. Perform the atomic symlink swap
# `ln -snf` is the key. It atomically creates/replaces the symbolic link.
# The old directory is still there, but Nginx will no longer write to it.
sudo ln -snf "$NEW_CACHE_DIR_NAME" "$CACHE_SYMLINK_PATH"
echo "Atomically swapped symlink '$CACHE_SYMLINK_PATH' to point to '$NEW_CACHE_DIR_NAME'."

# 3. Reload Nginx gracefully
# This ensures Nginx starts using the new cache directory for new requests.
echo "Sending reload signal to Nginx in container '$NGINX_CONTAINER_NAME'..."
docker exec "$NGINX_CONTAINER_NAME" nginx -s reload

echo "--- Atomic Cache Rotation Complete ---"
echo "The new cache directory is now active. Old cache directory can be purged later."
