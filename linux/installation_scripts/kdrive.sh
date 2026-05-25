#!/bin/bash
set -e

REMOTE_VERSION=$(curl -s "https://aur.archlinux.org/rpc/?v=5&type=info&arg[]=kdrive-appimage" | jq -r '.results[0].Version' | cut -d'-' -f1)

# Ensure we actually got a version string back
if [ -z "$REMOTE_VERSION" ] || [ "$REMOTE_VERSION" == "null" ]; then
    echo "Error: Could not retrieve remote version metadata."
    exit 1
fi

# Determine the actual non-root user's home directory path dynamically
LOCAL_BIN="/home/$SUDO_USER/programs/kDrive.AppImage"
if [ -f "$LOCAL_BIN" ]; then
    # Use --version to get the exact version string. Catch any crashes with || true so set -e doesn't kill the script.
    RAW_VERSION=$("$LOCAL_BIN" --version 2>&1 || true)
    LOCAL_VERSION=$(echo "$RAW_VERSION" | sed -n 's/.*kDrive version \([0-9.]*\) (build \([0-9]*\)).*/\1.\2/p' | head -n1)
    [ -z "$LOCAL_VERSION" ] && LOCAL_VERSION="0.0.0.0"
else
    LOCAL_VERSION="0.0.0.0" # Triggers install if no local file exists
fi

# Update kdrive if needed
if [ "$LOCAL_VERSION" == "$REMOTE_VERSION" ]; then
    echo "kDrive is up to date (Version: $LOCAL_VERSION). Skipping installation."
    exit 0
else
    echo "New update found! Upgrading from $LOCAL_VERSION to $REMOTE_VERSION..."
    
    # Ensure directory path exists
    mkdir -p "$(dirname "$LOCAL_BIN")"
    
    # Run download & replacement sequence
    DOWNLOAD_URL="https://download.storage.infomaniak.com/drive/desktopclient/kDrive-${REMOTE_VERSION}-amd64.AppImage"
    
    # Temporary download target to prevent overwriting a running app binary mid-stream
    TMP_BIN="${LOCAL_BIN}.tmp"
    wget -O "$TMP_BIN" "$DOWNLOAD_URL"
    chmod +x "$TMP_BIN"
    
    # Atomically replace old binary
    mv "$TMP_BIN" "$LOCAL_BIN"
    
    # Extract official kDrive icon
    echo "Extracting official kDrive icon..."
    PROGRAMS_DIR="$(dirname "$LOCAL_BIN")"
    cd "$PROGRAMS_DIR"
    # Extract the whole folder just in case the filename changes or is named kdrive-win.png
    ./kDrive.AppImage --appimage-extract "usr/share/icons/hicolor/512x512/apps" > /dev/null 2>&1 || true
    if ls "$PROGRAMS_DIR/squashfs-root/usr/share/icons/hicolor/512x512/apps/"*.png 1> /dev/null 2>&1; then
        mv "$PROGRAMS_DIR/squashfs-root/usr/share/icons/hicolor/512x512/apps/"*.png "$PROGRAMS_DIR/kdrive.png"
    fi
    rm -rf "$PROGRAMS_DIR/squashfs-root"
    
    # Correct file ownership back to the non-root user if run with sudo
    if [ -n "$SUDO_USER" ]; then
        chown "$SUDO_USER:$SUDO_USER" "$LOCAL_BIN"
        chown "$SUDO_USER:$SUDO_USER" "$PROGRAMS_DIR/kdrive-win.png" 2>/dev/null || true
    fi
    
    echo "kDrive successfully updated to $REMOTE_VERSION."
fi