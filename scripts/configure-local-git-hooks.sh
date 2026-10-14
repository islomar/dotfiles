#!/bin/bash
#
# Enables the dotfiles git hooks in one repository only, by setting core.hooksPath in its local config.
# Use configure-global-git-hooks.sh instead to enable them in every repository.
#
# Usage: configure-local-git-hooks.sh [repository-path]   Defaults to the current directory.
# Undo:  git config --unset core.hooksPath
#
set -euo pipefail

main() {
	local repo_path="${1:-.}"

	local repo_root
	if ! repo_root="$(git -C "$repo_path" rev-parse --show-toplevel 2>/dev/null)"; then
		printf 'Not a Git repository: %s\n' "$repo_path" >&2
		exit 1
	fi

	local current_hooks_path
	current_hooks_path="$(git -C "$repo_root" config --local --get core.hooksPath || true)"

	if [[ "$current_hooks_path" == "$hooks_dir" ]]; then
		printf 'Already configured: %s uses %s\n' "$repo_root" "$hooks_dir"
		exit 0
	fi

	if [[ -n "$current_hooks_path" ]]; then
		printf 'Not changed: %s already sets core.hooksPath = %s (Husky or a similar tool).\n' \
			"$repo_root" "$current_hooks_path" >&2
		printf 'Replacing it would turn off those hooks. To replace it anyway, run:\n' >&2
		printf '  git -C %q config core.hooksPath %q\n' "$repo_root" "$hooks_dir" >&2
		exit 1
	fi

	git -C "$repo_root" config core.hooksPath "$hooks_dir"
	printf 'Configured: %s uses %s\n' "$repo_root" "$hooks_dir"
}

# Resolve symlinks, because install_scripts.sh links this script into ~/bin.
hooks_dir="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../hooks" && pwd)"

main "$@"
