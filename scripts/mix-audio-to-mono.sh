#!/bin/bash
set -euo pipefail

# https://askubuntu.com/questions/1393150/is-it-possible-to-force-all-audio-to-mono

# pactl list sinks

pactl load-module module-remap-sink \
  sink_name=mono \
  master="$(pactl info | awk -F': ' '/Default Sink/ {print $2}')" \
  channels=2 \
  channel_map=mono,mono

