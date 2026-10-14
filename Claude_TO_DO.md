<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents** *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Claude to-do](#claude-to-do)
  - [Open](#open)
  - [Done](#done)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Claude to-do

Tasks for Claude Code. Start a session with "work through Claude_TO_DO.md".
When a task is done, tick it and add the commit hash.

## Open

- [ ] I see the existence of ~/workspace/my-notes/AI/Hugging_Face_MCP_Course/src/.venv/
  - Add any .venv to .gitignore global, as well as other equivalent languages folders
  - Delete from anywhere in this repository
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
- [ ] **`cat` output too dark on a black terminal** (`bat` config, dotfiles shell aliases)
  - `cat` runs `bat`: an earlier error in this session printed `[bat error]` for a `cat` command.
  - The bat theme makes file content hard to read on a black background.
  - Dotfiles commit `0e934e2` ("Pick bat theme from GNOME color scheme instead of macOS defaults")
    chooses the theme. Check which theme it picks with a dark GNOME color scheme.
  - Pick a high-contrast dark theme (try `bat --list-themes`), set it with `BAT_THEME` or in `bat`'s config,
    and make sure the setting is tracked in dotfiles.

## Done
