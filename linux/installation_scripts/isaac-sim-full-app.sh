#!/bin/bash
set -e

# Download the full Isaac Sim app
wget -O /tmp/isaac-sim-standalone-$ISAAC_SIM_VERSION-linux-x86_64.zip https://downloads.isaacsim.nvidia.com/isaac-sim-standalone-$ISAAC_SIM_VERSION-linux-x86_64.zip
unzip -o /tmp/isaac-sim-standalone-$ISAAC_SIM_VERSION-linux-x86_64.zip -d /home/$SUDO_USER/programs/
