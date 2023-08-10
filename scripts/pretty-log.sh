#!/usr/bin/env zsh
set -euo pipefail

# https://github.com/CodelyTV/dotfiles/blob/f7f24f37ce011871e62348ad714c5c31eda3b2af/scripts/git/pretty-log

##? Git log filtering
#?? 1.0.0
##?
##? Usage:
##?    pretty-log


commit=$(
  git log --graph \
    --color=always \
    --date=human \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%ad by %an" |
    fzf --ansi --no-sort \
      --preview '(git diff-tree --no-commit-id --name-status -r {2})' \
      --preview-window right:35%
)

commit_hash=$(echo ${commit} | awk '{print $2}')

echo ${commit_hash} | tr -d '\n' | xclip