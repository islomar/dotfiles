#!/usr/bin/env bash

set -euo pipefail

# https://itsfoss.com/free-up-space-ubuntu-linux/#5-remove-older-versions-of-snap-applications-intermediate-knowledge-

sudo apt-get autoremove

# Clean up APT cache in Ubuntu
sudo apt-get autoclean
sudo apt-get clean

# Clear systemd journal logs [Intermediate knowledge]
sudo journalctl --vacuum-time=3d

# Remove older versions of Snap applications [Intermediate knowledge]
./delete-old-snaps-revisions.sh

# Clean the thumbnail cache [Intermediate knowledge]
rm -rf ~/.cache/thumbnails/*