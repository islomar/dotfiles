#!/bin/bash
set -euo pipefail

cp -pr $DOTFILES_PATH/scripts/* $HOME/bin
npm install -g tldr