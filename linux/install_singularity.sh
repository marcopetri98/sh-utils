#!/bin/bash
set -e

sudo apt-get update
sudo apt-get install -y \
   autoconf \
   automake \
   cryptsetup \
   fuse2fs \
   git \
   fuse \
   libfuse-dev \
   libseccomp-dev \
   libtool \
   pkg-config \
   runc \
   squashfs-tools \
   squashfs-tools-ng \
   uidmap \
   wget \
   zlib1g-dev

# Only from ubuntu 24.04 and newer
sudo apt-get install -y libsubid-dev

# Install Go as it is needed for singularity
export GO_VERSION=1.27.1 OS=linux ARCH=amd64

wget https://dl.google.com/go/go$GO_VERSION.$OS-$ARCH.tar.gz
# Extracting over an existing /usr/local/go produces a broken install
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzvf go$GO_VERSION.$OS-$ARCH.tar.gz
rm go$GO_VERSION.$OS-$ARCH.tar.gz

# Add go to path for this script (sourcing ~/.bashrc is a no-op in
# non-interactive shells) and persist it for future shells
export PATH=/usr/local/go/bin:$PATH
grep -qxF 'export PATH=/usr/local/go/bin:$PATH' ~/.bashrc || \
   echo 'export PATH=/usr/local/go/bin:$PATH' >> ~/.bashrc

# Download singularity and install it
export VERSION=4.5.0

wget https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-ce-${VERSION}.tar.gz
tar -xzf singularity-ce-${VERSION}.tar.gz
cd singularity-ce-${VERSION}

./mconfig
make -C builddir
sudo make -C builddir install
