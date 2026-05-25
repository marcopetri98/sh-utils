#!/bin/bash
set -e

OLD_LAUNCHER="/home/$SUDO_USER/.local/share/applications/zotero.desktop"
if [ -f "$OLD_LAUNCHER" ]; then
    echo "Removing legacy local launcher file..."
    rm "$OLD_LAUNCHER"
fi
curl -sL https://raw.githubusercontent.com/retorquere/zotero-pkg/master/install.sh | bash