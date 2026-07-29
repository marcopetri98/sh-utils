#!/bin/bash
set -e

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--help)
            echo "Usage: $0"
            exit 0
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            if [[ $PATH_GIVEN -eq 1 ]]; then
                echo "Unexpected extra argument: $1" >&2
                exit 1
            fi
            SYNC_PATH="$1"
            PATH_GIVEN=1
            shift
            ;;
    esac
done

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

sudo apt install ros-jazzy-desktop
sudo apt install ros-jazzy-ros-base
sudo apt install ros-dev-tools

# ==============================================================================
# STAGE 4: Setup environment
# ==============================================================================
source /opt/ros/jazzy/setup.bash