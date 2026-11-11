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

# doctoc at a pinned version, for the Claude Code hook that updates Markdown tables of contents.
# A fixed path keeps npx from running a doctoc found in the node_modules of the project being edited.
if command -v npm >/dev/null; then
    npm install --silent --prefix "$HOME/.local/share/doctoc" doctoc@2.5.0
    ln -sf "$HOME/.local/share/doctoc/node_modules/.bin/doctoc" "$HOME/.local/bin/doctoc"
else
    echo "Skipping doctoc: npm is not installed." >&2
fi

# JetBrains Toolbox shell scripts on PATH for the desktop session (takes effect at the next login).
mkdir -p "$HOME/.config/environment.d"
ln -sf "$HOME/.dotfiles/config/environment.d/999-jetbrains-toolbox.conf" "$HOME/.config/environment.d/999-jetbrains-toolbox.conf"

# Claude Code global instructions. RTK.md sits next to CLAUDE.md because CLAUDE.md imports it with @RTK.md.
mkdir -p "$HOME/.claude"
ln -sf "$HOME/.dotfiles/config/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
ln -sf "$HOME/.dotfiles/config/claude/RTK.md" "$HOME/.claude/RTK.md"

# Claude Code skills kept in this repository. Each folder becomes a link in ~/.claude/skills.
mkdir -p "$HOME/.claude/skills"
for skill_dir in "$HOME/.dotfiles/config/claude/skills"/*/; do
    ln -sfn "${skill_dir%/}" "$HOME/.claude/skills/$(basename "$skill_dir")"
done

# Claude Code settings: hooks, plugins, and the status line read by the Stream Deck.
# The hooks play sounds from ~/workspace/dotfiles-private/sounds (see the README there).
# The file lives in the private repository ~/workspace/dotfiles-private, because it holds machine details.
# A settings.json that is a regular file is kept as settings.json.bak before it is replaced by the link.
claude_settings="$HOME/.claude/settings.json"
claude_settings_private="$HOME/workspace/dotfiles-private/claude/settings.json"
if [[ -f "$claude_settings_private" ]]; then
    if [[ -f "$claude_settings" && ! -L "$claude_settings" ]]; then
        mv "$claude_settings" "$claude_settings.bak"
    fi
    ln -sf "$claude_settings_private" "$claude_settings"
else
    echo "Skipping Claude Code settings: clone the private repository to ~/workspace/dotfiles-private first." >&2
fi

# Claude Code hook sounds come from Mixkit. Their license forbids redistribution, so they are not in this repository.
# Download any sound missing from the private repository.
claude_sounds="$HOME/workspace/dotfiles-private/sounds"
if [[ -d "$HOME/workspace/dotfiles-private" ]]; then
    mkdir -p "$claude_sounds"
    while read -r sound url; do
        if [[ ! -f "$claude_sounds/$sound" ]]; then
            curl -fsSL "$url" -o "$claude_sounds/$sound" || echo "Could not download $sound from $url" >&2
        fi
    done <<'EOF'
on-agent-complete.wav https://assets.mixkit.co/active_storage/sfx/951/951.wav
on-agent-need-attention.wav https://assets.mixkit.co/active_storage/sfx/2575/2575.wav
on-agent-idle-magic-notification-ring.wav https://assets.mixkit.co/active_storage/sfx/2344/2344.wav
EOF
fi


unamestr="$(uname)"
if [[ "$unamestr" == 'Linux' ]]; then
    # shellcheck source=/dev/null
    source "$DOTFILES_PATH/linux/install-linux-files.sh"
elif [[ "$unamestr" == 'Darwin' ]]; then
    # shellcheck source=/dev/null
    source "$DOTFILES_PATH/osx/install-osx-files.sh"
fi
