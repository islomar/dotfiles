#!/bin/bash
set -euo pipefail

pip install -r "$DOTFILES_PATH/langs/python/requirements.txt"
echo "Python apps imported!"

xargs -I_ npm install -g "_" < "$DOTFILES_PATH/langs/js/global_modules.txt"
echo "NPM apps imported!"

unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
    echo "Install additional Linux apps..."
elif [[ "$unamestr" == 'Darwin' ]]; then
    echo "Install additional Mac apps..."
    brew services stop --all
    brew bundle --file="$HOMEBREW_BUNDLE_FILE_PATH" --force
    echo "Brew apps imported!"
fi