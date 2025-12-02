#!/bin/bash
# This script will install appimg from a local clone.

set -e  # Exit on error

APP_NAME="appimg"
PROJECT_ROOT="$(dirname "$0")"/.. # Go up one level from install/ to the project root

echo "Installing $APP_NAME from local clone..."

# --- Install appimg executable ---
INSTALL_PATH="/usr/local/bin/$APP_NAME"

echo "Copying $APP_NAME script to $INSTALL_PATH..."
if [ ! -f "$PROJECT_ROOT/$APP_NAME" ]; then
    echo "Error: appimg executable not found at $PROJECT_ROOT/$APP_NAME."
    exit 1
fi
sudo cp "$PROJECT_ROOT/$APP_NAME" "$INSTALL_PATH"
sudo chmod +x "$INSTALL_PATH"

# Verify installation
if [ -x "$INSTALL_PATH" ]; then
    echo "Installation complete!"
    echo "You can now run '$APP_NAME' from anywhere."
else
    echo "Installation failed: $INSTALL_PATH is not executable."
    exit 1
fi

# --- Install man page ---
MAN_SOURCE_PATH="$PROJECT_ROOT/man/man1/appimg.1"
MAN_INSTALL_DIR="/usr/local/share/man/man1"
MAN_INSTALL_PATH="$MAN_INSTALL_DIR/appimg.1"

echo "Installing man page from $MAN_SOURCE_PATH..."
if [ ! -f "$MAN_SOURCE_PATH" ]; then
    echo "Error: Man page not found at $MAN_SOURCE_PATH."
    exit 1
fi

sudo mkdir -p "$MAN_INSTALL_DIR"
sudo cp -f "$MAN_SOURCE_PATH" "$MAN_INSTALL_PATH"
sudo gzip -f "$MAN_INSTALL_PATH" # Gzip the man page

# --- Ensure ~/.appimages exists and install placeholder icon ---
APPIMG_DIR="$HOME/.appimages"
PLACEHOLDER_ICON_SOURCE="$PROJECT_ROOT/assets/icons/placeholder-icon.png"
PLACEHOLDER_ICON_DEST="$APPIMG_DIR/placeholder-icon.png"

echo "Ensuring directory exists: $APPIMG_DIR"
mkdir -p "$APPIMG_DIR"

echo "Copying placeholder-icon.png to $APPIMG_DIR/..."
if [ -f "$PLACEHOLDER_ICON_SOURCE" ]; then
    cp "$PLACEHOLDER_ICON_SOURCE" "$PLACEHOLDER_ICON_DEST"
else
    echo "Warning: placeholder-icon.png not found at $PLACEHOLDER_ICON_SOURCE. Skipping."
fi

echo "Local installation and setup complete!"
