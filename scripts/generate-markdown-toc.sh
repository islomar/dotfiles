#!/bin/bash
set -euo pipefail

main() {
	require_command "git" "https://git-scm.com/downloads" \
		"Install Git using your operating system's package manager"

	repo_root="$(git rev-parse --show-toplevel)"
	cd "$repo_root"

	check_node_requirements
	update_toc_in_markdown_files
}

update_toc_in_markdown_files() {
	detect_changed_files | update_table_of_contents
}

detect_changed_files() {
	git diff --cached --name-only --diff-filter=ACMRT -- '*.md' '*.markdown'
}

update_table_of_contents() {
	local markdown_file

	while IFS= read -r markdown_file; do
		[[ -n "$markdown_file" ]] || continue
		npx --no-install doctoc "$markdown_file"
		git add -- "$markdown_file"
	done
}

check_node_requirements() {
	require_command "node" "https://nodejs.org/" "Install Node.js from the URL above"
	require_command "npm" "https://docs.npmjs.com/downloading-and-installing-node-js-and-npm" \
		"Install Node.js and npm from the URL above"
	require_command "npx" "https://docs.npmjs.com/cli/commands/npx" \
		"Install Node.js and npm from the URL above"

	if ! npx --no-install doctoc --help >/dev/null 2>&1; then
		printf 'Missing required npm package: doctoc\nInstall it from: %s\nExample: npm install --global doctoc\n' \
			"https://www.npmjs.com/package/doctoc" >&2
		exit 1
	fi
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

main