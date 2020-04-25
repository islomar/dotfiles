#!/usr/bin/env bash

selected=$(ps axc | awk 'NR > 1' | awk '{print substr($0,index($0,$5))}' | sort -u | fzf)

if [ ! -z $1 ]; then
  lsof -r 2 -c "$selected"
else
  lsof -c "$selected"
fi

