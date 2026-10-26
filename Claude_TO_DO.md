<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Contents

- [Claude to-do](#claude-to-do)
  - [Open](#open)
  - [Done](#done)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Claude to-do

Tasks for Claude Code. Start a session with "work through Claude_TO_DO.md".
When a task is done, tick it and add the commit hash.

## Open

- [ ] **Chain more hook types** (`hooks/`, `scripts/run-local-git-hook.sh`)
  - Repositories with their own `commit-msg` or `prepare-commit-msg` in `.git/hooks` stop running them
    under the global `core.hooksPath`.
  - Add a hook file and a script for each, following the pattern of the other four hooks.

## Done

- [x] **Ignore virtualenvs and other language folders globally** (`home/.gitignore_global`). Commit `39c7fe6`.
  - Added Python entries (`.venv/`, `venv/`, `__pycache__/`, `*.py[cod]`, tool caches) and Elixir entries (`.elixir_ls/`, `/_build/`, `/deps/`).
  - `/_build/` and `/deps/` match only at a repository root, so a `deps/` folder deeper in another project is not hidden.
  - `~/workspace/my-notes/AI/Hugging_Face_MCP_Course/src/.venv/` was never tracked. Delete it to free disk space.
- [x] **`cat` output too dark on a black terminal** (`home/.zshrc`). Commit `730b327`.
  - The old alias picked the light `GitHub` theme because GNOME `color-scheme` is `'default'` on this machine.
  - The alias is now `bat --theme=auto`. bat 0.25 reads the terminal background and uses `BAT_THEME_DARK` (`Monokai Extended`)
    or `BAT_THEME_LIGHT` (`GitHub`).
- [x] **tdd-guard leftovers** (`~/.claude/settings.json`, npm, Homebrew). Commit `bad8ca7`.
  - Removed the deny rule `Read(.claude/tdd-guard/**)`. No repository under `~/workspace` has a `.claude/tdd-guard/` folder.
  - Uninstalled the npm copy and the Homebrew copy (1.1.0).
  - Removed `tdd-guard` from `langs/js/global_modules.txt`.
- [x] **`apps/` and the "no tests" check** (`scripts/detect-files-without-tests.sh`). Commit `ffbc483`.
  - The check reads an optional `.no-tests-ignore` at the repository root: one extended regex per line.
    It leaves out matching paths before it looks for tests.
  - This repository's `.no-tests-ignore` contains `^apps/`. Other repositories have no such file and keep the full check.
