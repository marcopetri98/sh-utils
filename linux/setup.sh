#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
  echo "This script is meant to be run with sudo." >&2
  exit 1
fi

# Default variable values
WORK=0
ROBOTICS=0
ISAAC_SIM_VERSION="5.1.0"

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  -h, --help                          Show this help message"
            echo "  -w, --work                          Enable work profile setup"
            echo "  -r, --robotics                      Enable robotics-specific installations"
            echo "  -i, --isaac-sim-version <version>   Specify Isaac Sim version (default: 5.1.0)"
            exit 0
            ;;
        -w|--work)
            WORK=1
            shift
            ;;
        -r|--robotics)
            ROBOTICS=1
            shift
            ;;
        -i|--isaac-sim-version)
            if [[ "$2" != "6.0.0" && "$2" != "5.1.0" && "$2" != "5.0.0" && "$2" != "4.5.0" ]]; then
                echo "Invalid Isaac Sim version specified. Allowed values are '6.0.0', '5.1.0', '5.0.0', and '4.5.0'."
                exit 1
            fi
            ISAAC_SIM_VERSION="$2"
            echo "Will install client for Isaac Sim version: $ISAAC_SIM_VERSION"
            shift 2
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            # Handle positional arguments (non-flags) here if needed
            echo "Positional argument: $1"
            shift
            ;;
    esac
done

export ISAAC_SIM_VERSION

# Install commands
bash ./linux/install_commands.sh

# Update and add repositories
apt-get update
chmod +x ./linux/installation_scripts/*.sh
chmod +x ./linux/*.sh

# Install basic dependencies for linux
apt-get install -y ca-certificates \
    curl \
    apt-transport-https \
    binutils \
    gnome-terminal \
    network-manager-openconnect \
    network-manager-openconnect-gnome \
    flatpak \
    cmake \
    gnupg
curl -sL https://raw.githubusercontent.com/retorquere/zotero-pkg/master/install.sh | bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
snap install gedit

# Install basic software dependencies
snap install bitwarden
snap install vivaldi
snap install thunderbird

# Entertainment
snap install spotify

# Writing and office apps
snap install libreoffice

# Research
curl -fsSL https://tailscale.com/install.sh | bash
apt-get install -y zotero
apt-get install -y filezilla

# Development
apt-get install -y git
bash ./linux/installation_scripts/docker.sh

wget -O /tmp/vscode-install.deb https://update.code.visualstudio.com/latest/linux-deb-x64/stable
apt-get install -y /tmp/vscode-install.deb
rm /tmp/vscode-install.deb

# Messaging apps
snap install telegram-desktop

# Windows execution of apps
flatpak install flathub com.usebottles.bottles

# Install uv for python
curl -LsSf https://astral.sh/uv/install.sh | bash

# Work profile
if [[ $WORK -eq 1 ]]; then
    bash ./linux/work.sh
fi

# Isaac Sim Apps
if [[ $ROBOTICS -eq 1 ]]; then
    echo "Setting up ROS2..."
    bash ./linux/ros2.sh
fi

# Give docker permissions to the user
groupadd docker
usermod -aG docker $SUDO_USER
chown root:docker /var/run/docker.sock

# Manage apps that are not shipped either with snap or apt
echo "=============================="
echo "Creating programs directory..."
if [ -d "/home/$SUDO_USER/programs" ]; then
    echo "Directory already exists. Skipping creation."
else
    mkdir /home/$SUDO_USER/programs
    echo "Directory created successfully."
fi

# Install Anytype
wget -O /tmp/anytype.deb https://anytype-release.fra1.cdn.digitaloceanspaces.com/anytype_0.56.1_amd64.deb
apt-get install -y /tmp/anytype.deb
rm /tmp/anytype.deb

# Discord
echo "=============================="
echo "Setting up Discord updater..."
cp -p ./linux/installation_scripts/discord.sh /home/$SUDO_USER/programs/discord.sh
sed "s/__USER__/$SUDO_USER/g" ./linux/autostart/discord-updater.desktop > "/home/$SUDO_USER/.config/autostart/discord-updater.desktop"

# Isaac Sim Apps
if [[ $ROBOTICS -eq 1 ]]; then
    echo "=============================="
    echo "Setting up Isaac Sim Apps..."
    bash ./linux/robotics.sh
    sed "s/__USER__/$SUDO_USER/g" ./linux/applications/isaac-sim.desktop > "/home/$SUDO_USER/.local/share/applications/isaac-sim.desktop"
fi

# AnyDesk
echo "=============================="
echo "Setting up AnyDesk..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY -o /etc/apt/keyrings/keys.anydesk.com.asc
chmod a+r /etc/apt/keyrings/keys.anydesk.com.asc
echo "deb [signed-by=/etc/apt/keyrings/keys.anydesk.com.asc] https://deb.anydesk.com all main" | tee /etc/apt/sources.list.d/anydesk-stable.list > /dev/null
apt update
apt install -y anydesk

# Claude code
echo "=============================="
echo "Setting up Claude Code Desktop..."
curl -fsSLo /usr/share/keyrings/claude-desktop-archive-keyring.asc https://downloads.claude.ai/claude-desktop/key.asc
gpg --show-keys /usr/share/keyrings/claude-desktop-archive-keyring.asc
echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/claude-desktop-archive-keyring.asc] https://downloads.claude.ai/claude-desktop/apt/stable stable main" | tee /etc/apt/sources.list.d/claude-desktop.list
apt update && apt install claude-desktop
