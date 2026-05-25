#!/bin/bash

# Update repositories
apt-get update

# Install basic dependencies for linux
apt install -y curl
snap install gedit

# Install basic software dependencies
snap install bitwarden
snap install vivaldi

# Development
apt install -y git
snap install code --classic