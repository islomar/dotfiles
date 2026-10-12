#!/bin/bash
set -euo pipefail

# Export Python apps
pipx list --short | cut -d ' ' -f 1 > "$DOTFILES_PATH/langs/python/pipx-packages.txt"
echo "Python apps exported!"

# Export NPM apps
ls -1 /usr/local/lib/node_modules | grep -v npm > "$DOTFILES_PATH/langs/js/global_modules.txt"
echo "NPM apps exported!"

unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
    echo "Exporting additional Linux apps..."
elif [[ "$unamestr" == 'Darwin' ]]; then
    echo "Exporting additional Mac apps..."
    brew services stop --all
    brew bundle dump --file="$HOMEBREW_BUNDLE_FILE_PATH" --force
    echo "Brew apps exported!"
fi