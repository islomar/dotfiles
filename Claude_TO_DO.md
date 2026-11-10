<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents** *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Claude to-do](#claude-to-do)
  - [Open](#open)
    - [Backups](#backups)
    - [Security](#security)
    - [System](#system)
    - [This repository](#this-repository)
    - [Personal](#personal)
    - [Blog](#blog)
  - [Done](#done)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Claude to-do

The single list of pending work for Claude Code, across all repositories and sessions.
Start a session with "work through Claude_TO_DO.md".
When you finish a task, tick it, move it to Done, and add the commit hash or the date.

This repository is public.
Describe tasks without secrets, key identifiers, private folder names, names of other people, or the security state of any machine or account.
Never name a company or project the user worked for, and never name their private workspaces.
Details that break these rules go in `~/workspace/dotfiles-private/claude-todo.md`, in a private repository.

## Open

### Backups

- [ ] **Work through the Backups section of the private to-do file** (urgent) (`~/workspace/dotfiles-private/claude-todo.md`)
- [ ] **Decide which data-disk folders go to the cloud backup**
  - The folder list is in the private to-do file.
- [ ] **Shrink the cloud backup once an external disk takes the daily backups** (important)
  - Trigger: the user has an external hard disk in daily use as the main backup.
  - The cloud then keeps only data that is hard to replace.
    Large re-downloadable content leaves the cloud backup and stays on the external disk.
  - Steps: agree the new Déjà Dup include list with the user;
    apply it with `/usr/bin/gsettings`;
    run a backup and confirm a new snapshot;
    then remove old snapshots, run `restic prune`, and empty the cloud trash. Pruned files go to the trash and still count against the quota.
  - Check that the external disk backup covers every folder removed from the cloud before removing it.
- [ ] **Check the first full phone-photo backup** (`apps/phone-sync`). Due 2026-11-02.
  - Run `apps/phone-sync/setup-phone-sync.sh doctor`. The backup's last run must show `success`.
  - The backup folder must hold `DCIM`, `Pictures`, `WhatsApp` and `Telegram`, about 5 GB in total.
- [ ] **Confirm the phone photos are in a cloud snapshot** (`apps/phone-sync`)
  - The originals in `~/Pictures/Phone` fall under `$HOME`, which Déjà Dup already backs up every 3 days.
    The daily copy on the data disk stays out of the cloud on purpose: it would upload the same 5 GB twice.
  - Done when a Déjà Dup snapshot after 2026-11-01 14:12 restores a file from `~/Pictures/Phone/WhatsApp`.
  - Keep `~/Pictures/Phone` in the include list when the task above shrinks the cloud backup.
- [ ] **Review FreeFileSync before its next run**
  - Reorganized the data disk on 2026-10-31.
    The preview will show large deletions and copies.
  - The steps for the backup disk are in the private to-do file.

### Security

- [ ] **Work through the Security section of the private to-do file** (`~/workspace/dotfiles-private/claude-todo.md`)

### System

- [ ] **Buy and test the 2 TB external SSD** (`linux/external-ssd.md`)
  - Research and the pick are in that file. Check the price again before buying.
  - After buying, run the "Test after buying" steps and record the results in the same file.
  - Then the cloud-backup task in Backups can start.

### This repository

- [ ] **Chain more hook types** (`hooks/`, `scripts/run-local-git-hook.sh`)
  - Repositories with their own `commit-msg` or `prepare-commit-msg` in `.git/hooks` stop running them under the global `core.hooksPath`.
  - Add a hook file and a script for each, following the pattern of the other four hooks.
- [ ] **Fix the pre-push hook on large pushes** (`scripts/detect-push-without-tests.sh`)
  - It passes the file list as one argument. Above 128 KiB the script fails with `Argument list too long` and blocks the push.
  - Pass the list on stdin or in a temporary file.
- [ ] **Check that the Claude Code settings symlink survives a settings change** (the file is in the private repository)
  - After the next "always allow" answer or `/config` change, run `readlink ~/.claude/settings.json`.
  - Empty output means Claude Code replaced the link with a regular file.
    Then move the new content back into the repository and restore the link.

### Personal

- [ ] **Work through the dated personal item in the private to-do file** (due 2026-11-09) (`~/workspace/dotfiles-private/claude-todo.md`)

### Blog

Blog tasks live in `_TODO.md` in the blog's repository.

## Done

- [x] **Finish the TV remote script** (the script is in the private repository, `tv/tv`). 2026-11-07.
  - Dropped input switching: the TV ignores the HDMI keys and has nothing connected.
- [x] **Keep Claude Code sessions and export them to Markdown**. 2026-11-05.
  - `cleanupPeriodDays` is 3650 in the Claude Code settings.
  - A `SessionEnd` hook runs `scripts/claude-session-export`. The output folder is in the private to-do file.
- [x] **Install the gcloud and Atlassian (`acli`) CLIs and upgrade uv**. 2026-11-05.
  - Projects that use these CLIs track their own work in their own repositories.
  - gcloud lives in `~/.local/share/google-cloud-sdk`, linked from `~/.local/bin`. `acli` is in `~/.local/bin`. pipx manages uv.
- [x] **Run `scripts/setup-yubikey-pam.sh setup` and `enroll` for real**. 2026-11-05.
  - `setup` on the configured machine made a backup, kept the credential and left one rule per PAM file. `doctor` found no problems.
  - `enroll` replaced the credential. `pamu2fcfg` asked for the key's FIDO2 PIN before the touch; the new credential still needs only a touch.
  - `sudo -v` and `pkexec /usr/bin/true` both worked with a touch.
- [x] **Turn off OTP mode on the YubiKey**. 2026-11-05.
  - Ran `ykman config usb --disable OTP` and `ykman config nfc --disable OTP`. A touch no longer types a code.
  - Slot 1 still holds the factory credential. `ykman config usb --enable OTP` brings it back if a service needs Yubico OTP.
- [x] **Kernel cleanup**. 2026-11-05.
  - Rebooted into 7.0.0-42. `ollama list` shows its 8 models, so the `/etc/fstab` bind mount works at boot.
  - Purged the `rc` packages of 7.0.0-34 (image, modules, ZFS modules) and `/lib/modules/7.0.0-34-generic`.
  - 7.0.0-38 stays installed as the fallback kernel.
- [x] **Prune the Déjà Dup repository**. 2026-11-01.
  - Removed 28.7 GiB left by the failed runs; 155 GiB remain.
    `restic check` found no errors.
- [x] **First cloud backup (Déjà Dup)**. 2026-11-01.
  - Snapshot saved at 14:12 after 50 minutes; about 71 GiB uploaded.
    Earlier runs had failed with HTTP 500 or had stopped partway.
- [x] **Move the program folders on the data disk**. 2026-11-01.
  - `ollama-models`: moved, `/etc/fstab` bind mount updated.
  - `jetbrains-apps`: moved with Toolbox closed; paths rewritten in Toolbox state, channels, scripts and app launchers.
  - `docker-desktop`: deleted, a leftover of an uninstalled Docker Desktop.
  - Toolbox shell scripts on PATH for the desktop session (`config/environment.d/999-jetbrains-toolbox.conf`).
    Named `999-*` because `/etc/environment` resets PATH in `99-environment.conf`.
- [x] **Small clean-ups after the reorganization**. 2026-11-01.
  - Moved personal files off the system partition.
  - Deleted the 37 `.bak-reorg`, `.bak-reorg-1` and `.bak-carpetas` config backups.
  - OBS `Audio_calls` simple-mode recording path now points to an existing folder.
  - Removed the expired `kernel-cleanup-reminder` user timer and its unit files.
  - Deleted Homebrew's GNOME settings keyfile.
    Always use `/usr/bin/gsettings` or `dconf`: Homebrew's `gsettings` writes a file GNOME ignores.
- [x] **Reorganize the data disk**. 2026-10-31.
  - Updated app configs, Files bookmarks, Chrome bookmarks and Déjà Dup paths.
- [x] **Password-protect sensitive folders with gocryptfs** (`scripts/encrypted-folders`).
  Commit `a13813d`. 2026-11-01.
  - `status` and `unlock` flag files saved into a locked folder.
    The folder list is in `~/.config/encrypted-folders/folders`, outside this repository.
- [x] **Version the global Claude Code instructions** (`config/claude/`).
  Commit `9401a81`. 2026-11-01.
- [x] **Shrink course videos over 500 MB to HEVC** (83 GB to 50 GB). 2026-11-01.
- [x] **Ignore virtualenvs and other language folders globally** (`home/.gitignore_global`).
  Commit `a355a38`.
  - Added Python entries (`.venv/`, `venv/`, `__pycache__/`, `*.py[cod]`, tool caches) and Elixir entries (`.elixir_ls/`, `/_build/`, `/deps/`).
  - `/_build/` and `/deps/` match only at a repository root, so a `deps/` folder deeper in another project is not hidden.
- [x] **`cat` output too dark on a black terminal** (`home/.zshrc`).
  Commit `70b5d39`.
  - The old alias picked the light `GitHub` theme because GNOME `color-scheme` is `'default'` on this machine.
  - The alias is now `bat --theme=auto`. bat 0.25 reads the terminal background and uses `BAT_THEME_DARK` (`Monokai Extended`) or `BAT_THEME_LIGHT` (`GitHub`).
- [x] **tdd-guard leftovers** (`~/.claude/settings.json`, npm, Homebrew).
  Commit `774ae4e`.
  - Removed the deny rule `Read(.claude/tdd-guard/**)`.
    No repository under `~/workspace` has a `.claude/tdd-guard/` folder.
  - Uninstalled the npm copy and the Homebrew copy (1.1.0).
  - Removed `tdd-guard` from `langs/js/global_modules.txt`.
- [x] **`apps/` and the "no tests" check** (`scripts/detect-files-without-tests.sh`).
  Commit `c30fc0b`.
  - The check reads an optional `.no-tests-ignore` at the repository root: one extended regex per line.
    It leaves out matching paths before it looks for tests.
  - This repository's `.no-tests-ignore` contains `^apps/`.
    Other repositories have no such file and keep the full check.
- [x] **Security assessment of this repository**. 2026-11-01.
  - No live credentials found in the tree or history.
  - Removed the old IDE export and other work references; enabled GitHub secret scanning and push protection.
  - Rewrote the history to remove the same references and recreated the GitHub repository.
  - Added a gitleaks scan of staged changes to the pre-commit hook (`scripts/detect-secrets.sh`).
