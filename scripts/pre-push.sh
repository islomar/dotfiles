#!/bin/bash
#
# Logic of the pre-push hook: rejects pushes with source changes but no test changes.
# Then runs the repo's own .git/hooks/pre-push, if present.
# Stdin: one line per pushed ref (<local ref> <local sha> <remote ref> <remote sha>).
#
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Git passes the pushed refs on stdin. Both scripts need them.
pushed_refs="$(cat)"

# A here-string adds a newline, so empty input would reach the scripts as one blank ref line.
replay_pushed_refs() {
	[[ -z "$pushed_refs" ]] || printf '%s\n' "$pushed_refs"
}

replay_pushed_refs | bash "$script_dir/detect-push-without-tests.sh"
replay_pushed_refs | bash "$script_dir/run-local-git-hook.sh" pre-push "$@"
