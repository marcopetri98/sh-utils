#!/bin/bash
set -e

# Get the final URL of the latest version from Discord's API
LATEST_URL=$(curl -Ls -o /dev/null -w '%{url_effective}' 'https://discord.com/api/download?platform=linux&format=deb')
FILE_NAME=$(basename "$LATEST_URL")

# Check if we already have this version installed
if dpkg -s discord 2>/dev/null | grep -q "Version: ${FILE_NAME//[^0-9.]/}"; then
    # Already updated! Launch Discord silently in the background
    gnome-terminal --title="Discord Updater" --wait -- bash -c "
        echo 'Discord already up to date!...';
        sleep 1;
    "
else
    # An update is found. Open a small terminal window to ask for sudo password and install
    gnome-terminal --title="Discord Updater" --wait -- bash -c "
        echo 'New Discord update found ($FILE_NAME).';
        echo 'Please enter your password to install it:';
        curl -L '$LATEST_URL' -o '/tmp/$FILE_NAME' && \
        sudo dpkg -i '/tmp/$FILE_NAME' && \
        rm '/tmp/$FILE_NAME';
        echo 'Discord update complete!...';
        sleep 1;
    "
fi