#!/bin/bash

# Update and add repositories
apt-get update
chmod +x installation_scripts/*.sh

# Install basic dependencies for linux
apt-get install -y ca-certificates \
    curl \
    apt-transport-https \
    binutils \
    gnome-terminal \
    network-manager-openconnect \
    network-manager-openconnect-gnome \
    flatpak \
    cmake
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
snap install tailscale
apt-get install -y zotero
apt-get install -y filezilla

# Development
apt-get install -y git
./installation_scripts/docker.sh
snap install code --classic

# Messaging apps
snap install telegram-desktop

# Windows execution of apps
flatpak install flathub com.usebottles.bottles

# Install uv for python
curl -LsSf https://astral.sh/uv/install.sh | bash

# Setup work specific environment
bash work.sh

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

# Discord
echo "=============================="
echo "Setting up Discord updater..."
cp -p ./linux/installation_scripts/discord.sh /home/$SUDO_USER/programs/discord.sh
sed "s/__USER__/$SUDO_USER/g" ./linux/autostart/discord-updater.desktop > "/home/$SUDO_USER/.config/autostart/discord-updater.desktop"

# Kdrive
echo "=============================="
echo "Setting up Kdrive cloud..."
bash ./linux/installation_scripts/kdrive.sh
sed "s/__USER__/$SUDO_USER/g" ./linux/applications/kdrive.desktop > "/home/$SUDO_USER/.local/share/applications/kdrive.desktop"
apt install -y gnome-shell-extension-appindicator

# AnyDesk
echo "=============================="
echo "Setting up AnyDesk..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY -o /etc/apt/keyrings/keys.anydesk.com.asc
chmod a+r /etc/apt/keyrings/keys.anydesk.com.asc
echo "deb [signed-by=/etc/apt/keyrings/keys.anydesk.com.asc] https://deb.anydesk.com all main" | tee /etc/apt/sources.list.d/anydesk-stable.list > /dev/null
apt update
apt install -y anydesk
