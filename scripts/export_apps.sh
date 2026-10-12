#!/bin/bash
set -euo pipefail

DOTFILES_PATH="${DOTFILES_PATH:-$HOME/.dotfiles}"
HOMEBREW_BUNDLE_FILE_PATH="${HOMEBREW_BUNDLE_FILE_PATH:-$DOTFILES_PATH/osx/Brewfile}"

# Export Python apps
pipx list --short | cut -d ' ' -f 1 > "$DOTFILES_PATH/langs/python/pipx-packages.txt"
echo "Python apps exported!"

# Export NPM apps
npm_global_modules="$(npm root -g)"
npm ls --global --depth=0 --parseable \
    | sed -n "s|^$npm_global_modules/||p" \
    | { grep -vx 'npm' || true; } \
    | sort > "$DOTFILES_PATH/langs/js/global_modules.txt"
echo "NPM apps exported!"

unamestr="$(uname)"
if [[ "$unamestr" == 'Linux' ]]; then
    echo "Exporting additional Linux apps..."
elif [[ "$unamestr" == 'Darwin' ]]; then
    echo "Exporting additional Mac apps..."
    brew services stop --all
    brew bundle dump --file="$HOMEBREW_BUNDLE_FILE_PATH" --force
    echo "Brew apps exported!"
fi