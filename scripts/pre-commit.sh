#!/bin/bash
#
# Logic of the pre-commit hook: test detection, doctoc TOC update, rumdl and Vale on staged Markdown.
# Then runs the repo's own .git/hooks/pre-commit, if present.
#
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$script_dir/load-tool-paths.sh"

bash "$script_dir/detect-commit-without-tests.sh"
bash "$script_dir/generate-markdown-toc.sh"
bash "$script_dir/check-markdown.sh" --staged
bash "$script_dir/run-local-git-hook.sh" pre-commit "$@"
