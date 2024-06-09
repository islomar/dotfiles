#!/bin/bash
set -eu

# Removes old revisions of snaps
# https://itsfoss.com/free-up-space-ubuntu-linux/#5-remove-older-versions-of-snap-applications-intermediate-knowledge-
# CLOSE ALL SNAPS BEFORE RUNNING THIS

snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        snap remove "$snapname" --revision="$revision"
    done