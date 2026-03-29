#!/usr/bin/env bash
#
# To be configured as a pre-push hook
# Rejects pushes that include source-file changes
# without also including corresponding test-file changes.
# This encourages developers to include tests with their changes.
# To add a new language, define appropriate SOURCE, TEST, and IGNORE patterns and call the check function `check_for_tests_in_commit_for_language` for those patterns.
#

set -euo pipefail

function main {
  get_pushed_files
  PWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  "$PWD/detect-files-without-tests.sh" "$PUSHED_FILES" "pre-push"
  exit 0
}

function get_pushed_files {
  PUSHED_FILES=$(git diff HEAD~1 HEAD --name-only)

  if [ -z "$PUSHED_FILES" ]; then
    exit 0
  fi
}

main
