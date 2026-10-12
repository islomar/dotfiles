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
    streamcontroller_data="$HOME/.var/app/com.core447.StreamController/data"
    streamcontroller_export="$DOTFILES_PATH/apps/streamcontroller"
    if compgen -G "$streamcontroller_data/pages/*.json" >/dev/null; then
        rm -rf "$streamcontroller_export"
        mkdir -p "$streamcontroller_export/pages" "$streamcontroller_export/settings" "$streamcontroller_export/Assets"
        cp -p "$streamcontroller_data"/pages/*.json "$streamcontroller_export/pages/"
        cp -p "$streamcontroller_data/settings/pages.json" "$streamcontroller_export/settings/"
        cp -pr "$streamcontroller_data/settings/decks" "$streamcontroller_export/settings/"
        cp -pr "$streamcontroller_data/Assets/AssetManager" "$streamcontroller_export/Assets/"
        # Keep the OBS WebSocket password out of the repo
        sed -i -E "s#(obsws://[^/]+/)[^'\" \\\\]+#\\1OBS_WEBSOCKET_PASSWORD#g" "$streamcontroller_export"/pages/*.json
        # Round the Weather button coordinates to 2 decimals (about 1 km) so the repo
        # does not show an exact address. Values that are not numbers are cleared.
        weather_filter='(.. | objects | select(.id? == "com_core447_Weather::Weather") | .settings) |=
            with_entries(if (.key == "lat" or .key == "lon")
                then .value |= (try ((tonumber * 100 | round) / 100 | tostring) catch "")
                else . end)'
        grep -l 'com_core447_Weather::Weather' "$streamcontroller_export"/pages/*.json | while IFS= read -r page; do
            page_tmp="$(mktemp)"
            jq --indent 4 "$weather_filter" "$page" >"$page_tmp"
            mv "$page_tmp" "$page"
        done
        echo "StreamController pages exported!"
    fi
elif [[ "$unamestr" == 'Darwin' ]]; then
    echo "Exporting additional Mac apps..."
    brew services stop --all
    brew bundle dump --file="$HOMEBREW_BUNDLE_FILE_PATH" --force
    echo "Brew apps exported!"
fi