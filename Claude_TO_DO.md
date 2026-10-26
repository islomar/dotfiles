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

- [ ] **tdd-guard leftovers** (`~/.claude/settings.json`, npm)
  - Decide whether to remove the deny rule `Read(.claude/tdd-guard/**)`. tdd-guard no longer runs.
  - Run `npm uninstall -g tdd-guard`.
- [ ] **Make the global git hooks opt-in** (`home/.gitconfig`)
  - `home/.gitconfig` contains `hooksPath = ~/.dotfiles/hooks`,
    so any machine that links it gets the hooks in every repository.
  - Move machine-specific settings such as `hooksPath` into an untracked file
    that `~/.gitconfig` loads with `[include]`.
  - Make `scripts/configure-global-git-hooks.sh` write to that file.
- [ ] **`apps/` and the "no tests" check** (`scripts/detect-files-without-tests.sh`)
  - Commits and pushes that change `apps/chrome-extension-v1.6.3/` need `--no-verify`.
  - An ignore pattern for `apps/` would also skip `apps/` in other repositories, because the hooks are global.
    Find a way to limit it to this repository.
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
