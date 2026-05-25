#!/bin/bash

# Update and add repositories
curl -sL https://raw.githubusercontent.com/retorquere/zotero-pkg/master/install.sh | bash
apt-get update

# Install basic dependencies for linux
apt-get install -y ca-certificates curl apt-transport-https binutils
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
snap install docker
snap install code --classic

# Messaging apps
snap install telegram-desktop

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
cp ./linux/installation_scripts/discord.sh /home/$SUDO_USER/programs/discord.sh
chmod +x /home/$SUDO_USER/programs/discord.sh
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