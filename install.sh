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

# Install man page
MAN_PATH="/usr/local/share/man/man1"
echo "Installing man page to $MAN_PATH"
sudo mkdir -p "$MAN_PATH"
sudo cp -f "man/man1/appimg.1" "$MAN_PATH/appimg.1"
sudo gzip -f "$MAN_PATH/appimg.1"

# ------------------------------------------------------------
# Ensure ~/.appimages exists
# ------------------------------------------------------------
APPIMG_DIR="$HOME/.appimages"
mkdir -p "$APPIMG_DIR"
echo "Ensured directory exists: $APPIMG_DIR"

# Move placeholder-icon.png into ~/.appimages
if [ -f "assets/icons/placeholder-icon.png" ]; then
    echo "Moving placeholder-icon.png → $APPIMG_DIR/"
    cp "assets/icons/placeholder-icon.png" "$APPIMG_DIR/"
else
    echo "Warning: placeholder-icon.png not found in assets/icons/."
fi

echo "Installation and setup complete!"
