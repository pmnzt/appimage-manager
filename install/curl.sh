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

REPO_BASE_URL="https://github.com/pmnzt/appimage-manager/archive/$RELEASE_TAG.tar.gz"
TMP_DIR=$(mktemp -d)
EXTRACT_DIR="$TMP_DIR/appimage-manager-${RELEASE_TAG#v}"

echo "Installing $APP_NAME ..."

# Download and extract source code
echo "Downloading and extracting $APP_NAME source code..."
curl -sSL "$REPO_BASE_URL" -o "$TMP_DIR/source.tar.gz"
tar -xzf "$TMP_DIR/source.tar.gz" -C "$TMP_DIR"

# Check if extraction was successful
if [ ! -d "$EXTRACT_DIR" ]; then
    echo "Error: Failed to extract $APP_NAME source code."
    exit 1
fi

# Copy appimg script
echo "Copying $APP_NAME script..."
cp "$EXTRACT_DIR/appimg" "$TMP_DIR/$APP_NAME"
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
cp -f "$EXTRACT_DIR/man/man1/appimg.1" "$TMP_DIR/man/man1/appimg.1"

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
cp "$EXTRACT_DIR/assets/icons/placeholder-icon.png" "$TMP_DIR/assets/icons/placeholder-icon.png"
if [ -f "$TMP_DIR/assets/icons/placeholder-icon.png" ]; then
    echo "Moving placeholder-icon.png → $APPIMG_DIR/"
    cp "$TMP_DIR/assets/icons/placeholder-icon.png" "$APPIMG_DIR/"
else
    echo "Warning: placeholder-icon.png not found in assets/icons."
fi

echo "Installation and setup complete!"

# Clean up temporary directory
rm -rf "$TMP_DIR"