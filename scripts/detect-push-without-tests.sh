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

ZERO_SHA_PATTERN='^0+$'

# Git passes one line per pushed ref on stdin:
#   <local ref> <local sha> <remote ref> <remote sha>
function get_pushed_files {
  PUSHED_FILES=""
  while read -r _local_ref local_sha _remote_ref remote_sha; do
    # Branch deletion: nothing is pushed
    if [[ "$local_sha" =~ $ZERO_SHA_PATTERN ]]; then
      continue
    fi

    if [[ "$remote_sha" =~ $ZERO_SHA_PATTERN ]]; then
      # New branch: only commits not already on any remote
      COMMIT_RANGE=("$local_sha" --not --remotes)
    else
      COMMIT_RANGE=("$remote_sha..$local_sha")
    fi

    PUSHED_FILES+=$(git log --format= --name-only --diff-filter=ACMR "${COMMIT_RANGE[@]}")$'\n'
  done

  PUSHED_FILES=$(echo "$PUSHED_FILES" | sed '/^$/d' | sort -u)

  if [ -z "$PUSHED_FILES" ]; then
    exit 0
  fi
}

main
