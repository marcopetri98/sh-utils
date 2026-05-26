#!/bin/bash
set -e

# Install dependencies to use palo alto global protect vpn with GUI
apt install -y python3-gi \
    gir1.2-gtk-3.0 \
    'gir1.2-webkit2-4.*' \
    libgirepository-2.0-dev \
    libcairo2-dev \
    pkg-config

uv tool install https://github.com/dlenski/gp-saml-gui/archive/master.zip
echo "alias openvpn=\"gp-saml-gui -P --gateway --clientos=Linux gp-deib-saml.vpn.polimi.it\"" >> ~/.bashrc

apt install gnome-shell-extension-manager