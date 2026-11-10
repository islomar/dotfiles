#!/bin/bash
#
# Installs dependencies and rebuilds when dependency files changed between <old-rev> and HEAD.
# Called by the post-merge and post-rewrite hooks.
#
# Usage: install-dependencies-on-change.sh <old-rev>
#
set -euo pipefail

changed_files="$(git diff-tree -r --name-only --no-commit-id "$1" HEAD)"

check_run() {
	if echo "$changed_files" | grep --quiet "$1"; then
		echo " * changes detected in $1"
		echo " * running $2"
		eval "$2"
	fi
}

tool_versions_command_to_install_dependencies() {
  asdf install
  mix local.hex --force
  mix local.rebar --force
  mix clean
  mix escript.install hex protobuf 0.15.0 --force
  mix protoc
  mix setup
}

# Installs and builds in each folder whose package.json, package-lock.json or yarn.lock changed.
# Runs inside that folder: run from the repository root, npm would climb to the nearest
# package.json above it (for example ~/package.json) and install that project instead.
ts_js_install_dependencies_where_changed() {
  local dirs dir
  dirs="$(echo "$changed_files" | grep -E '(^|/)(package\.json|package-lock\.json|yarn\.lock)$' | xargs -r -n1 dirname | sort -u || true)"
  for dir in $dirs; do
    if [[ ! -f "$dir/package.json" ]]; then
      continue
    fi
    echo " * changes detected in $dir/ (package.json, package-lock.json or yarn.lock)"
    (
      cd "$dir"
      if [[ -f yarn.lock ]]; then
        yarn install
      else
        npm install
      fi
      npm run build --if-present
    )
  done
}

# Runs `make build` once per Makefile that serves a folder whose pyproject.toml or poetry.lock changed.
# The Makefile is the nearest one with a `build` target, in that folder or a parent up to the repository root.
# Skips a folder with no such Makefile instead of failing on "No rule to make target 'build'".
python_install_dependencies_where_changed() {
  local dirs dir candidate make_dirs="" make_dir
  dirs="$(echo "$changed_files" | grep -E '(^|/)(pyproject\.toml|poetry\.lock)$' | xargs -r -n1 dirname | sort -u || true)"
  for dir in $dirs; do
    if [[ ! -f "$dir/pyproject.toml" ]]; then
      continue
    fi
    candidate="$dir"
    make_dir=""
    while true; do
      if [[ -f "$candidate/Makefile" ]] && grep --quiet -E '^build:' "$candidate/Makefile"; then
        make_dir="$candidate"
        break
      fi
      if [[ "$candidate" == "." ]]; then
        break
      fi
      candidate="$(dirname "$candidate")"
    done
    if [[ -z "$make_dir" ]]; then
      echo " * changes detected in $dir/ (pyproject.toml or poetry.lock), but no Makefile with a build target: skipped"
      continue
    fi
    make_dirs+="$make_dir"$'\n'
  done
  for make_dir in $(echo -n "$make_dirs" | sort -u); do
    echo " * changes detected in pyproject.toml or poetry.lock: running make build in $make_dir/"
    make -C "$make_dir" build
  done
}

python_install_dependencies_where_changed

ts_js_install_dependencies_where_changed

ELIXIR_DEPENDENCY_FILES_TO_DETECT="mix.exs\|mix.lock"
ELIXIR_COMMAND_TO_INSTALL_DEPENDENCIES="mix deps.get && mix compile"
check_run "$ELIXIR_DEPENDENCY_FILES_TO_DETECT" "$ELIXIR_COMMAND_TO_INSTALL_DEPENDENCIES"

TOOL_VERSIONS_DEPENDENCY_FILES_TO_DETECT=".tool-versions"
check_run "$TOOL_VERSIONS_DEPENDENCY_FILES_TO_DETECT" tool_versions_command_to_install_dependencies
