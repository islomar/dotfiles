#!/usr/bin/env bash
#
# To be configured as a pre-commit or pre-push hook
# Rejects commits/pushes that add/modify source files
# without also adding/modifying corresponding test files.
# This encourages developers to include tests with their changes.
# To add a new language, define appropriate SOURCE, TEST, and IGNORE patterns and call the check function `check_for_tests_in_commit_for_language` for those patterns.
#

set -euo pipefail

# Patterns that identify SOURCE files (excluding tests, stories, configs, etc.)
JS_TS_SOURCE_PATTERN='\.(js|jsx|ts|tsx)$'
ELIXIR_SOURCE_PATTERN='\.(ex|exs)$'

# Patterns that identify TEST files
JS_TS_TEST_PATTERN='\.(test|spec)\.(js|jsx|ts|tsx)$|__tests__/.*\.(js|jsx|ts|tsx)$'
JS_TS_ERROR_MESSAGE="   Please include at least one test file matching:\n     *.test.(js|jsx|ts|tsx)\n     *.spec.(js|jsx|ts|tsx)\n  __tests__/*.{js,jsx,ts,tsx}"
ELIXIR_TEST_PATTERN='_test\.exs$|_spec\.exs$|test/.*\.exs$'
ELIXIR_ERROR_MESSAGE="   Please include at least one test file matching:\n     *_test.exs\n     *_spec.exs\n     test/*.exs"

# Files to always ignore (configs, build scripts, type declarations, etc.)
JS_TS_IGNORE_PATTERN='(\.config\.|\.eslintrc|\.prettierrc|jest\.|vite\.|webpack\.|rollup\.|babel\.|tsconfig|\.d\.ts$|/node_modules/|\.storybook/|\.stories\.|/scripts/|/migrations/|/types/|/constants/|/index\.(js|jsx|ts|tsx)$)'
ELIXIR_IGNORE_PATTERN='(\.config\.|\.formatter\.|\.credo\.|\.dialyzer\.|\.exs$|/test_helpers/|/migrations/|/scripts/|/types/|/constants/|/index\.(ex|exs)$)'

PRE_COMMIT_ERROR_MESSAGE="❌  pre-commit: No test files found in this commit!"
PRE_PUSH_ERROR_MESSAGE="❌  pre-push: No test files found in commits being pushed!"

function main {
  STAGED_FILES=$1
  GIT_PHASE_FOR_SEARCHING_FILES=$2 # "pre-commit" or "pre-push"
  if [ -z "$STAGED_FILES" ]; then
    echo "No files detected"
    exit 0
  fi

  check_for_tests_for_language_patterns "$JS_TS_SOURCE_PATTERN" "$JS_TS_TEST_PATTERN" "$JS_TS_IGNORE_PATTERN" "$JS_TS_ERROR_MESSAGE"
  check_for_tests_for_language_patterns "$ELIXIR_SOURCE_PATTERN" "$ELIXIR_TEST_PATTERN" "$ELIXIR_IGNORE_PATTERN" "$ELIXIR_ERROR_MESSAGE"
  exit 0
}

function check_for_tests_for_language_patterns {
    local SOURCE_PATTERN="$1"
    local TEST_PATTERN="$2"
    local IGNORE_PATTERN="$3"
    local ERROR_MESSAGE="$4"
    collect_source_files_and_check_for_tests_if_needed
}

function collect_source_files_and_check_for_tests_if_needed {
  SOURCE_FILES=()
  while IFS= read -r file; do
    # Match source pattern, exclude test pattern, exclude ignore pattern
    if echo "$file" | grep -qE "$SOURCE_PATTERN" \
       && ! echo "$file" | grep -qE "$TEST_PATTERN" \
       && ! echo "$file" | grep -qE "$IGNORE_PATTERN"; then
      SOURCE_FILES+=("$file")
    fi
  done <<< "$STAGED_FILES"

  # Only enforce test presence when source files changed
  if [ ${#SOURCE_FILES[@]} -gt 0 ]; then
    check_for_tests_in_pattern "$TEST_PATTERN"
  fi
}

function check_for_tests_in_pattern {
  HAS_TESTS=false
  while IFS= read -r file; do
    if echo "$file" | grep -qE "$TEST_PATTERN"; then
      HAS_TESTS=true
      break
    fi
  done <<< "$STAGED_FILES"

  if [ "$HAS_TESTS" = false ]; then
    show_error_and_exit
  fi
}

function show_error_and_exit {
    if [ "$GIT_PHASE_FOR_SEARCHING_FILES" = "pre-commit" ]; then
      HEADER_ERROR_MESSAGE="$PRE_COMMIT_ERROR_MESSAGE"
      GIT_SUBCOMMAND_TEXT="commit"
    else
      HEADER_ERROR_MESSAGE="$PRE_PUSH_ERROR_MESSAGE"
      GIT_SUBCOMMAND_TEXT="push"
    fi
    echo ""
    echo "$HEADER_ERROR_MESSAGE"
    echo ""
    echo "   The following source files were changed:"
    for f in "${SOURCE_FILES[@]}"; do
      echo "     • $f"
    done
    echo ""
    echo -e "$ERROR_MESSAGE"
    echo ""
    echo "   To skip this check (use sparingly):"
    echo "     git $GIT_SUBCOMMAND_TEXT --no-verify"
    echo ""

    exit 1
}

main "$1" "$2"