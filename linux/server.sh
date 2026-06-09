#!/bin/bash

# Update and add repositories
apt-get update
chmod +x ./linux/installation_scripts/*.sh

# Install basic dependencies for linux
apt-get install -y ca-certificates \
    curl \
    apt-transport-https \
    binutils \
    gnome-terminal \
    cmake \
    openssh-server \
    git

# Install docker and give permissions to the user
./linux/installation_scripts/docker.sh
groupadd docker
usermod -aG docker $SUDO_USER
chown root:docker /var/run/docker.sock

# VPN for remote access
curl -fsSL https://tailscale.com/install.sh | bash

# Install uv for python
curl -LsSf https://astral.sh/uv/install.sh | bash

# Manage apps that are not shipped either with snap or apt
echo "=============================="
echo "Creating programs directory..."
if [ -d "/home/$SUDO_USER/programs" ]; then
    echo "Directory already exists. Skipping creation."
else
    mkdir /home/$SUDO_USER/programs
    echo "Directory created successfully."
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
