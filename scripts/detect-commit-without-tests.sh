#!/usr/bin/env bash
#
# pre-commit hook
# Rejects commits that add/modify JavaScript or TypeScript source files
# without also adding/modifying corresponding test files.
#
# Install: cp pre-commit .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit

set -euo pipefail

# ---------- configuration ----------

# Patterns that identify SOURCE files (excluding tests, stories, configs, etc.)
SOURCE_PATTERN='\.(js|jsx|ts|tsx)$'

# Patterns that identify TEST files
TEST_PATTERN='\.(test|spec)\.(js|jsx|ts|tsx)$|__tests__/.*\.(js|jsx|ts|tsx)$'

# Files to always ignore (configs, build scripts, type declarations, etc.)
IGNORE_PATTERN='(\.config\.|\.eslintrc|\.prettierrc|jest\.|vite\.|webpack\.|rollup\.|babel\.|tsconfig|\.d\.ts$|/node_modules/|\.storybook/|\.stories\.|/scripts/|/migrations/|/types/|/constants/|/index\.(js|jsx|ts|tsx)$)'

# ---------- logic ----------

# Get staged files (added, copied, modified, renamed)
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACMR)

if [ -z "$STAGED_FILES" ]; then
  exit 0
fi

# Collect source files (non-test JS/TS files)
SOURCE_FILES=()
while IFS= read -r file; do
  # Match source pattern, exclude test pattern, exclude ignore pattern
  if echo "$file" | grep -qE "$SOURCE_PATTERN" \
     && ! echo "$file" | grep -qE "$TEST_PATTERN" \
     && ! echo "$file" | grep -qE "$IGNORE_PATTERN"; then
    SOURCE_FILES+=("$file")
  fi
done <<< "$STAGED_FILES"

# No source files changed — nothing to enforce
if [ ${#SOURCE_FILES[@]} -eq 0 ]; then
  exit 0
fi

# Check if ANY test file is included in the commit
HAS_TESTS=false
while IFS= read -r file; do
  if echo "$file" | grep -qE "$TEST_PATTERN"; then
    HAS_TESTS=true
    break
  fi
done <<< "$STAGED_FILES"

if [ "$HAS_TESTS" = true ]; then
  exit 0
fi

# ---------- failure output ----------

echo ""
echo "❌  pre-commit: No test files found in this commit!"
echo ""
echo "   The following source files were changed:"
for f in "${SOURCE_FILES[@]}"; do
  echo "     • $f"
done
echo ""
echo "   Please include at least one test file matching:"
echo "     *.test.(js|jsx|ts|tsx)"
echo "     *.spec.(js|jsx|ts|tsx)"
echo "     __tests__/*.{js,jsx,ts,tsx}"
echo ""
echo "   To skip this check (use sparingly):"
echo "     git commit --no-verify"
echo ""

exit 1