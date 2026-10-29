#!/bin/bash
#
# Puts Homebrew and nvm tools on PATH for git hooks.
# GUI clients such as WebStorm run git without ~/.zshrc, so brew and node are missing there.
# Source it from a hook script: . "$script_dir/load-tool-paths.sh"
#

brew_bin="/home/linuxbrew/.linuxbrew/bin/brew"
if ! command -v brew >/dev/null 2>&1 && [[ -x "$brew_bin" ]]; then
	eval "$("$brew_bin" shellenv)"
fi

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
# Prefer nvm's Node.js over Homebrew's, so hooks use the same version as the terminal.
if [[ "$(command -v node 2>/dev/null)" != "$NVM_DIR"/* && -s "$NVM_DIR/nvm.sh" ]]; then
	# nvm.sh is not safe under `set -eu`. It switches to the default Node.js version on load.
	set +eu
	. "$NVM_DIR/nvm.sh"
	set -eu
fi
