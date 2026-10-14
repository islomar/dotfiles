#!/bin/bash
#
# Logic of the post-rewrite hook. $1 is "amend" or "rebase".
# On rebase, installs dependencies and rebuilds when dependency files changed,
# comparing against ORIG_HEAD, the tip before the rebase.
# `git pull --rebase` with local commits runs this hook instead of post-merge.
# Then runs the repo's own .git/hooks/post-rewrite, if present.
# Stdin: one line per rewritten commit (<old sha> <new sha>).
#
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Git passes the rewritten commits on stdin. The repo's own hook needs them.
rewritten_commits="$(cat)"

if [[ "$1" == "rebase" ]]; then
	bash "$script_dir/install-dependencies-on-change.sh" ORIG_HEAD
fi
bash "$script_dir/run-local-git-hook.sh" post-rewrite "$@" <<< "$rewritten_commits"
