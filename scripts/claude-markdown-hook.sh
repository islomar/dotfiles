#!/bin/bash
#
# Claude Code PostToolUse hook for Edit and Write on Markdown files.
# Updates the doctoc table of contents, then runs rumdl with --fix.
# Issues rumdl cannot fix go to stderr with exit code 2, so Claude sees them and fixes them before commit time.
# Vale is left to the pre-commit hook: it is slow and only reports.
# Stdin: the hook payload as JSON. Settings: ~/.claude/settings.json, hooks.PostToolUse.
#
set -uo pipefail

file="$(jq -r '.tool_input.file_path // .tool_response.filePath // empty')"
case "$file" in
*.md | *.markdown) ;;
*) exit 0 ;;
esac
[[ -f "$file" ]] || exit 0

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
. "$script_dir/load-tool-paths.sh"

if grep -q 'START doctoc' "$file" && [[ -x "$HOME/.local/bin/doctoc" ]]; then
	"$HOME/.local/bin/doctoc" "$file" >/dev/null 2>&1 || true
fi

command -v rumdl >/dev/null 2>&1 || exit 0

# rumdl looks for a project config from the working directory.
cd "$(dirname "$file")" || exit 0
if ! output="$(rumdl check --fix "$file" 2>&1)"; then
	printf 'rumdl found issues it could not fix in %s:\n%s\n' "$file" "$output" >&2
	exit 2
fi
exit 0
