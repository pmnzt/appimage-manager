#!/usr/bin/env bash

set -e  # Exit on error

APP_NAME="appimg"
INSTALL_PATH="/usr/local/bin/$APP_NAME"

echo "Installing $APP_NAME ..."

# Check if file exists
if [ ! -f "$APP_NAME" ]; then
    echo "Error: $APP_NAME not found in current directory."
    exit 1
fi

# Make executable
chmod +x "$APP_NAME"

# Copy to /usr/local/bin (requires sudo unless root)
echo "Copying to $INSTALL_PATH"
sudo cp "$APP_NAME" "$INSTALL_PATH"

# Verify installation
if [ -x "$INSTALL_PATH" ]; then
    echo "Installation complete!"
    echo "You can now run '$APP_NAME' from anywhere."
else
    echo "Installation failed: $INSTALL_PATH is not executable."
    exit 1
fi
