#!/bin/bash
#
# Runs the repository's own hook from .git/hooks, if present.
# A global core.hooksPath makes Git skip .git/hooks, so the global hooks call this to chain to it.
#
# Usage: run-local-git-hook.sh <hook-name> [hook args...]
#
set -euo pipefail

main() {
	local hook_name="$1"
	shift

	local local_hook
	local_hook="$(git rev-parse --path-format=absolute --git-common-dir)/hooks/$hook_name"

	if [[ -x "$local_hook" && "$(realpath "$local_hook")" != "$(realpath "$global_hooks_dir/$hook_name")" ]]; then
		"$local_hook" "$@"
	fi
}

global_hooks_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../hooks" && pwd)"

main "$@"
