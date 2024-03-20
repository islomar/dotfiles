#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update
sudo apt-get install streamdeck-ui gnome-screenshot

mkdir ~/Pictures/StreamDeckIcons

cp -pr images/StreamDeckIcons/Configured/* ~/Pictures/StreamDeckIcons

echo "And... DONE! Now you can try and launch it running 'streamdeck'"