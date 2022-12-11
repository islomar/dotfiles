#!/bin/bash
set -euo pipefail

DOTFILES_PATH="$HOME/workspace/dotfiles"

cp -pr $DOTFILES_PATH/scripts/* $HOME/bin
npm install -g tldr
