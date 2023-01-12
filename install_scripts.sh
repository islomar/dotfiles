#!/bin/bash
set -euo pipefail

DOTFILES_PATH="$HOME/.dotfiles"

cp -pr $DOTFILES_PATH/scripts/* $HOME/bin
sudo npm install -g tldr
