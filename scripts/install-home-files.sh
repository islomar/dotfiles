#!/bin/bash
set -euo pipefail
export DOTFILES_PATH="$HOME/.dotfiles"


# diff $HOME/.bashrc $HOME/.dotfiles/home/.bashrc

ln -sf "$HOME/.dotfiles/home/.bashrc" "$HOME/.bashrc"
ln -sf "$HOME/.dotfiles/home/.zshrc" "$HOME/.zshrc"
ln -sf "$HOME/.dotfiles/home/.p10k.zsh" "$HOME/.p10k.zsh"
ln -sf "$HOME/.dotfiles/home/.vimrc" "$HOME/.vimrc"
ln -sf "$HOME/.dotfiles/home/.gitignore_global" "$HOME/.gitignore_global"
ln -sf "$HOME/.dotfiles/home/.gitattributes" "$HOME/.gitattributes"
ln -sf "$HOME/.dotfiles/home/.zshenv" "$HOME/.zshenv"
ln -sf "$HOME/.dotfiles/home/.tmux.conf" "$HOME/.tmux.conf"
ln -sf "$HOME/.dotfiles/home/.tmate.conf" "$HOME/.tmate.conf"
ln -sf "$HOME/.dotfiles/home/.gitconfig" "$HOME/.gitconfig"
mkdir -p "$HOME/.local/bin"
# The Stream Deck buttons in apps/streamcontroller run obs-ctl from this path
ln -sf "$HOME/.dotfiles/scripts/obs-ctl" "$HOME/.local/bin/obs-ctl"
mkdir -p "$HOME/.config/rumdl"
ln -sf "$HOME/.dotfiles/config/rumdl/rumdl.toml" "$HOME/.config/rumdl/rumdl.toml"

# Claude Code status line with the plan usage limits, also read by the Stream Deck.
# Only the statusLine key is set; the rest of settings.json stays as it is.
claude_settings="$HOME/.claude/settings.json"
mkdir -p "$(dirname "$claude_settings")"
[[ -f "$claude_settings" ]] || echo '{}' >"$claude_settings"
claude_settings_tmp="$(mktemp)"
jq '.statusLine = {"type": "command", "command": "~/.dotfiles/scripts/claude-limits statusline"}' \
    "$claude_settings" >"$claude_settings_tmp"
mv "$claude_settings_tmp" "$claude_settings"


unamestr="$(uname)"
if [[ "$unamestr" == 'Linux' ]]; then
    # shellcheck source=/dev/null
    source "$DOTFILES_PATH/linux/install-linux-files.sh"
elif [[ "$unamestr" == 'Darwin' ]]; then
    # shellcheck source=/dev/null
    source "$DOTFILES_PATH/osx/install-osx-files.sh"
fi
