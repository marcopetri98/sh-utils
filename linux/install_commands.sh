#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
  echo "This script is meant to be run with sudo." >&2
  exit 1
fi

USER_HOME="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
USER_GROUP="$(id -gn "$SUDO_USER")"
BASHRC="$USER_HOME/.bashrc"

# Create the update_system command for the user simplicity
chmod +x ./linux/commands/*
install -d -o "$SUDO_USER" -g "$USER_GROUP" "$USER_HOME/.local/bin"
install -m 755 -o "$SUDO_USER" -g "$USER_GROUP" ./linux/commands/* "$USER_HOME/.local/bin/"

# Make sure that .local/bin is in the PATH
if grep -qF '.local/bin' "$BASHRC"; then
  echo "Skipping: .local/bin already in $BASHRC"
else
  echo "Adding .local/bin to PATH in $BASHRC"
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$BASHRC"
  chown "$SUDO_USER:$SUDO_USER" "$BASHRC"
fi