#!/bin/bash
#
# Logic of the post-merge hook: installs dependencies and rebuilds when dependency files changed.
# Compares against HEAD@{1}, the tip before the merge.
# Then runs the repo's own .git/hooks/post-merge, if present.
#
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$script_dir/load-tool-paths.sh"

bash "$script_dir/install-dependencies-on-change.sh" 'HEAD@{1}'
bash "$script_dir/run-local-git-hook.sh" post-merge "$@"
