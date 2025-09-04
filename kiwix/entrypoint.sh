#!/bin/sh
# Entrypoint script for Kiwix server container
# Start cron daemon
crond

# Add cron job to restart kiwix-serve every night at 1am
echo "0 1 * * * /restart-kiwix-serve.sh" > /etc/crontabs/root


# Exit immediately if a command exits with a non-zero status.
set -e

# Define the path for the library file
ZIMS_PATH="/zims"
export LIBRARY_PATH="$ZIMS_PATH/library.xml"

# Check if there are any ZIM files in the zims directory
# The `find` command will exit with a status of 1 if no files are found.
# We use `|| true` to prevent the script from exiting if no ZIM files are present yet.
ZIM_FILES_EXIST=$(find "$ZIMS_PATH" -name "*.zim" -print -quit || true)

# If ZIM files exist, create the library file
if [ -n "$ZIM_FILES_EXIST" ]; then
    echo "ZIM files found. Creating library file at $LIBRARY_PATH..."
    # Create the library file from all .zim files in the /zims directory
    kiwix-manage "$LIBRARY_PATH" add "$ZIMS_PATH"/*.zim
    echo "Library file created successfully."
else
    echo "No ZIM files found in $ZIMS_PATH. Kiwix server will not start."
    exit 1
fi

# Execute the main command passed to the container (e.g., kiwix-serve)
# The --library flag tells kiwix-serve where to find the content catalog.
# "$@" passes along any arguments from the Dockerfile's CMD.
echo "Starting Kiwix server..."
exec /kiwix-serve-cmd.sh "$@"
