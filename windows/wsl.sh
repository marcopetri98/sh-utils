#!/bin/bash
set -e

################################################################################
# Setup ssh agent such that it always works with keys
################################################################################
sudo apt-get install -y keychain
shopt -s nullglob
sudo chmod 600 -R /home/$USER/.ssh
sudo chmod 700 /home/$USER/.ssh
keys=""
for p in /home/$USER/.ssh/*.pub; do
  k="${p%.pub}"
  [[ -f $k ]] || continue
  sudo chmod 600 "$k"; sudo chmod 644 "$p"
  keys+="$(basename "$k") "
done
if [[ -z $keys ]]; then
  echo "No .pub keys found in /home/$USER/.ssh: no keys will be added."
else
  read -rp "Add these keys to /home/$USER/.bashrc: ${keys}? [y/N] " ans
  if [[ $ans == [yY] ]]; then
    echo "eval \"\$(keychain --eval --quiet ${keys% })\"" >> /home/$USER/.bashrc
  else
    echo "No keys will be added."
  fi
fi

################################################################################
# Install homebrew
################################################################################
sudo apt-get install -y ca-certificates \
    build-essential

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo >> /home/$USER/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"' >> /home/$USER/.bashrc
source /home/$USER/.bashrc

################################################################################
# Install mutagen
################################################################################
brew trust mutagen-io/mutagen
brew install mutagen-io/mutagen/mutagen

################################################################################
# Install singularity
################################################################################
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
sudo rm go$GO_VERSION.$OS-$ARCH.tar.gz

# Add go to path for this script (sourcing /home/$USER/.bashrc is a no-op
# in non-interactive shells) and persist it for future shells
export PATH=/usr/local/go/bin:$PATH
grep -qxF 'export PATH=/usr/local/go/bin:$PATH' /home/$USER/.bashrc || \
   echo 'export PATH=/usr/local/go/bin:$PATH' >> /home/$USER/.bashrc

# Download singularity and install it
export VERSION=4.5.0

wget https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-ce-${VERSION}.tar.gz
tar -xzf singularity-ce-${VERSION}.tar.gz
cd singularity-ce-${VERSION}

./mconfig
make -C builddir
sudo make -C builddir install
