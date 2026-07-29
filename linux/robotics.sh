#!/bin/bash
set -e

# ==============================================================================
# STAGE 1: Setup NVIDIA container toolkit
# ==============================================================================
apt-get install -y --no-install-recommends \
   gnupg2

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

apt-get update
export NVIDIA_CONTAINER_TOOLKIT_VERSION=1.19.0-1
apt-get install -y \
    nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    nvidia-container-toolkit-base=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    libnvidia-container-tools=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
    libnvidia-container1=${NVIDIA_CONTAINER_TOOLKIT_VERSION}

# Configure docker for enabling it to use nvidia container toolkit
nvidia-ctk runtime configure --runtime=docker
systemctl restart docker

# ==============================================================================
# STAGE 2: Setup Vulkan tools
# ==============================================================================
apt-get install -y --no-install-recommends \
   libvulkan1

# ==============================================================================
# STAGE 3: Install Isaac Sim
# ==============================================================================
# Livestream client
bash ./linux/installation_scripts/isaac-sim-live-client.sh

# Full Isaac Sim app
bash ./linux/installation_scripts/isaac-sim-full-app.sh
