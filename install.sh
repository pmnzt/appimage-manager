#!/usr/bin/env bash

set -e  # Exit on error

APP_NAME="appimg"
REPO_API_URL="https://api.github.com/repos/pmnzt/appimage-manager"

# Get the latest release tag
RELEASE_TAG=$(curl -sSL "$REPO_API_URL/releases/latest" | grep -oP '"tag_name":\s*"\K[^"]+')

if [ -z "$RELEASE_TAG" ]; then
    echo "Error: Could not retrieve latest release tag."
    exit 1
fi

REPO_BASE_URL="https://github.com/pmnzt/appimage-manager/releases/download/$RELEASE_TAG"
TMP_DIR=$(mktemp -d)

echo "Installing $APP_NAME ..."

# Download appimg script
echo "Downloading $APP_NAME script..."
curl -sSL "$REPO_BASE_URL/appimg" -o "$TMP_DIR/$APP_NAME"
chmod +x "$TMP_DIR/$APP_NAME"

# Check if download was successful
if [ ! -f "$TMP_DIR/$APP_NAME" ]; then
    echo "Error: Failed to download $APP_NAME."
    exit 1
fi

# Make executable
INSTALL_PATH="/usr/local/bin/$APP_NAME"

# Copy to /usr/local/bin (requires sudo unless root)
echo "Copying to $INSTALL_PATH"
sudo cp "$TMP_DIR/$APP_NAME" "$INSTALL_PATH"

# Verify installation
if [ -x "$INSTALL_PATH" ]; then
    echo "Installation complete!"
    echo "You can now run '$APP_NAME' from anywhere."
else
    echo "Installation failed: $INSTALL_PATH is not executable."
    exit 1
fi

MAN_PATH="/usr/local/share/man/man1"

# Download and install man page
echo "Downloading man page..."
mkdir -p "$TMP_DIR/man/man1"
if ! curl -f -sSL "$REPO_BASE_URL/appimg.1" -o "$TMP_DIR/man/man1/appimg.1"; then
    echo "Error: Failed to download man page or man page not found (404)." >&2
    exit 1
fi

# Verify if the downloaded file is not empty
if [ ! -s "$TMP_DIR/man/man1/appimg.1" ]; then
    echo "Error: Downloaded man page is empty or invalid." >&2
    exit 1
fi
sudo mkdir -p "$MAN_PATH"
sudo cp -f "$TMP_DIR/man/man1/appimg.1" "$MAN_PATH/appimg.1"
sudo gzip -f "$MAN_PATH/appimg.1"

# ------------------------------------------------------------
# Ensure ~/.appimages exists
# ------------------------------------------------------------
MAN_PATH="/usr/local/share/man/man1"
APPIMG_DIR="$HOME/.appimages"
mkdir -p "$APPIMG_DIR"
echo "Ensured directory exists: $APPIMG_DIR"

# Download and move placeholder-icon.png into ~/.appimages
echo "Downloading placeholder-icon.png..."
mkdir -p "$TMP_DIR/assets/icons"
curl -sSL "$REPO_BASE_URL/placeholder-icon.png" -o "$TMP_DIR/assets/icons/placeholder-icon.png"
if [ -f "$TMP_DIR/assets/icons/placeholder-icon.png" ]; then
    echo "Moving placeholder-icon.png → $APPIMG_DIR/"
    cp "$TMP_DIR/assets/icons/placeholder-icon.png" "$APPIMG_DIR/"
else
    echo "Warning: placeholder-icon.png not found in assets/icons."
fi

echo "Installation and setup complete!"

# Clean up temporary directory
rm -rf "$TMP_DIR"
