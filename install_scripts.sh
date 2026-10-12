#!/bin/bash
set -euo pipefail

DOTFILES_PATH="$HOME/.dotfiles"

ln -sf $DOTFILES_PATH/scripts/* $HOME/bin/
sudo npm install -g tldr
