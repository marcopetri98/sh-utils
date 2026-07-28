#!/bin/bash
set -e

# ==============================================================================
# STAGE 1: Update system and install required packages
# ==============================================================================
sudo apt update && sudo apt install curl -y

# ==============================================================================
# STAGE 2: Setup sources for installation
# ==============================================================================
sudo apt install software-properties-common
sudo add-apt-repository universe

export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F'"' '{print $4}')
sudo curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb"
sudo dpkg -i /tmp/ros2-apt-source.deb

# ==============================================================================
# STAGE 3: Install ROS
# ==============================================================================
sudo apt update
sudo apt upgrade

sudo apt install ros-kilted-desktop
sudo apt install ros-kilted-ros-base
sudo apt install ros-dev-tools

# ==============================================================================
# STAGE 4: Setup environment
# ==============================================================================
source /opt/ros/kilted/setup.bash