#!/bin/bash
set -e

apt install libfuse2 -y

LOCAL_BIN="/home/$SUDO_USER/programs/isaacSim.AppImage"

# Temporary download target to prevent overwriting a running app binary mid-stream
DW_LINK=$(curl -L https://docs.isaacsim.omniverse.nvidia.com/$ISAAC_SIM_VERSION/installation/download.html | grep -i "isaacsim-webrtc-streaming-client.*linux" | grep -oP 'href="\K[^"]+')
TMP_BIN="/tmp/isaacsim-webrtc-streaming-client-${ISAAC_SIM_VERSION}-linux.AppImage"
curl -L $DW_LINK -o "$TMP_BIN"
chmod +x "$TMP_BIN"

# Atomically replace old binary
mv "$TMP_BIN" "$LOCAL_BIN"

# Extract official kDrive icon
echo "Extracting Isaac Sim WebRTC icon..."
PROGRAMS_DIR="$(dirname "$LOCAL_BIN")"
cd "$PROGRAMS_DIR"

# Extract the whole folder just in case the filename changes or is named kdrive-win.png
./isaacSim.AppImage --appimage-extract "usr/share/icons/hicolor/256x256/apps" > /dev/null 2>&1 || true
if ls "$PROGRAMS_DIR/squashfs-root/usr/share/icons/hicolor/256x256/apps/"*.png 1> /dev/null 2>&1; then
    mv "$PROGRAMS_DIR/squashfs-root/usr/share/icons/hicolor/256x256/apps/"*.png "$PROGRAMS_DIR/isaacSim.png"
fi
rm -rf "$PROGRAMS_DIR/squashfs-root"

# Correct file ownership back to the non-root user if run with sudo
if [ -n "$SUDO_USER" ]; then
    chown "$SUDO_USER:$SUDO_USER" "$LOCAL_BIN"
    chown "$SUDO_USER:$SUDO_USER" "$PROGRAMS_DIR/isaacSim.png" 2>/dev/null || true
fi