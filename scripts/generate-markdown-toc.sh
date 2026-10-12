#!/bin/bash
set -euo pipefail

function main {
	require_command "git" "https://git-scm.com/downloads" "sudo apt install git"

	repo_root="$(git rev-parse --show-toplevel)"
	cd "$repo_root"

	check_node_requirements
	update_toc_in_markdown_files
}

function update_toc_in_markdown_files {
	local -a markdown_files=()
	detect_changed_files markdown_files

	if ((${#markdown_files[@]} > 0)); then
		update_table_of_contents "${markdown_files[@]}"
	fi
}

function detect_changed_files {
	local -n changed_files="$1"
	local changed_files_file

	changed_files_file="$(mktemp)"
	if ! git diff --cached --name-only -z --diff-filter=ACMRT -- '*.md' '*.markdown' \
		>"$changed_files_file"; then
		rm -f "$changed_files_file"
		return 1
	fi

	mapfile -d '' -t changed_files <"$changed_files_file"
	rm -f "$changed_files_file"
}

function update_table_of_contents {
	local markdown_file

	for markdown_file in "$@"; do
		npx --no-install doctoc "$markdown_file"
	done
}

function check_node_requirements {
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

function require_command {
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