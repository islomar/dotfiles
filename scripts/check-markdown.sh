#!/bin/bash
#
# Lints Markdown files with rumdl (structure, style, relative links) and Vale (prose).
# rumdl fixes what it can automatically. Vale only reports.
#
# Usage:
#   check-markdown.sh [paths...]   Check the given paths, or all tracked Markdown files
#   check-markdown.sh --staged     Check staged Markdown files (pre-commit hook)
#
set -euo pipefail

DEFAULT_VALE_CONFIG="${DOTFILES_PATH:-$HOME/.dotfiles}/config/vale/.vale.ini"

main() {
	require_command "git" "https://git-scm.com/downloads" \
		"Install Git using your operating system's package manager"

	repo_root="$(git rev-parse --show-toplevel)"
	cd "$repo_root"

	if [[ "${1:-}" == "--staged" && -z "$(detect_staged_files)" ]]; then
		exit 0
	fi

	require_command "rumdl" "https://github.com/rvben/rumdl" "brew install rumdl"
	require_command "vale" "https://vale.sh/docs/install" "brew install vale"

	local status=0
	if [[ "${1:-}" == "--staged" ]]; then
		check_staged_files || status=1
	else
		check_files "$@" || status=1
	fi
	exit "$status"
}

check_staged_files() {
	local markdown_file
	local files_to_fix=()
	local files_to_lint_only=()

	while IFS= read -r markdown_file; do
		[[ -n "$markdown_file" ]] || continue
		if git diff --quiet -- "$markdown_file"; then
			files_to_fix+=("$markdown_file")
		else
			printf 'Not auto-fixing %s: it has unstaged changes\n' "$markdown_file" >&2
			files_to_lint_only+=("$markdown_file")
		fi
	done < <(detect_staged_files)

	local status=0
	if [[ ${#files_to_fix[@]} -gt 0 ]]; then
		rumdl check --fix "${files_to_fix[@]}" || status=1
		git add -- "${files_to_fix[@]}"
		check_prose "${files_to_fix[@]}" || status=1
	fi
	if [[ ${#files_to_lint_only[@]} -gt 0 ]]; then
		rumdl check "${files_to_lint_only[@]}" || status=1
		check_prose "${files_to_lint_only[@]}" || status=1
	fi
	return "$status"
}

check_files() {
	local markdown_file
	local files=()

	if [[ $# -gt 0 ]]; then
		files=("$@")
	else
		while IFS= read -r markdown_file; do
			[[ -n "$markdown_file" ]] && files+=("$markdown_file")
		done < <(git ls-files -- '*.md' '*.markdown')
	fi

	[[ ${#files[@]} -gt 0 ]] || return 0

	local status=0
	rumdl check --fix "${files[@]}" || status=1
	check_prose "${files[@]}" || status=1
	return "$status"
}

detect_staged_files() {
	git diff --cached --name-only --diff-filter=ACMRT -- '*.md' '*.markdown'
}

check_prose() {
	local vale_args=()
	if [[ ! -f ".vale.ini" && ! -f "_vale.ini" ]]; then
		vale_args=(--config "$DEFAULT_VALE_CONFIG")
	fi

	local vale_status=0
	vale ${vale_args[@]+"${vale_args[@]}"} "$@" || vale_status=$?

	# Vale only reports style issues. It blocks only when it cannot run (exit code 2).
	if [[ "$vale_status" -eq 2 ]]; then
		printf 'Vale failed to run. If a style is missing, download it with:\nvale sync %s\n' \
			"${vale_args[*]:-}" >&2
		return 2
	fi
	return 0
}

require_command() {
	local command_name="$1"
	local install_url="$2"
	local install_command="$3"

	if ! command -v "$command_name" >/dev/null 2>&1; then
		printf 'Missing required tool: %s\nInstall it from: %s\nExample: %s\n' \
			"$command_name" "$install_url" "$install_command" >&2
		exit 1
	fi
}

main "$@"
