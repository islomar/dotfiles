#!/usr/bin/env bash

set -euo pipefail

if docker ps >/dev/null 2>&1; then
  container=$(docker ps | awk '{if (NR!=1) print $1 ": " $(NF)}' | fzf --height 40%)

  if [[ -n $container ]]; then
    container_id=$(echo $container | awk -F ': ' '{print $1}')

    docker logs -f $container_id
  else
    echo "You haven't selected any container! ༼つ◕_◕༽つ"
  fi
else
  echo "Docker daemon is not running! (ಠ_ಠ)"
fi