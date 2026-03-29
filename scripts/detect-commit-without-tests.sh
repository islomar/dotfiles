#!/usr/bin/env bash
#
# To be configured as a pre-commit hook
# Rejects commits that add/modify source files
# without also adding/modifying corresponding test files.
# This encourages developers to include tests with their changes.
# To add a new language, define appropriate SOURCE, TEST, and IGNORE patterns and call the check function `check_for_tests_in_commit_for_language` for those patterns.
#

set -euo pipefail

function main {
  get_staged_files
  PWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  "$PWD/detect-files-without-tests.sh" "$STAGED_FILES" "pre-commit"
  exit 0
}

function get_staged_files {
  STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACMR)

  if [ -z "$STAGED_FILES" ]; then
    exit 0
  fi
}

main
