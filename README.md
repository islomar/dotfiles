<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Contents

- [dotfiles](#dotfiles)
  - [OS setups](#os-setups)
  - [Git hooks](#git-hooks)
    - [Setup](#setup)
    - [Turn the hooks off in one repository](#turn-the-hooks-off-in-one-repository)
    - [Hooks](#hooks)
    - [Repository hooks](#repository-hooks)
    - [Requirements](#requirements)
    - [Skip the hooks](#skip-the-hooks)
  - [Interesting tools](#interesting-tools)
    - [OSX](#osx)
    - [Linux](#linux)
  - [IntelliJ settings](#intellij-settings)
  - [How to set up my Stream Deck Mini](#how-to-set-up-my-stream-deck-mini)
    - [ydotool](#ydotool)
  - [Wacom tablet](#wacom-tablet)
    - [Installation](#installation)
    - [Software](#software)
    - [OpenBoard installation](#openboard-installation)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# dotfiles

All general purpose dot files with preferences and settings.

`git clone git@github.com:islomar/dotfiles.git ~/.dotfiles`

Some references used:

- [CodelyTV](https://github.com/CodelyTV/dotfiles)
- <https://dotfiles.github.io/>
- <https://github.com/marianudo/dotfiles>
- <https://github.com/google/styleguide/blob/gh-pages/intellij-java-google-style.xml>

## OS setups

- [Ubuntu](./install_ubuntu_apps.sh)
  - scripts/install-home-files.sh
- [OSX](./install_osx_apps.sh)
- Common:
  - [Install scripts](./install_scripts.sh)

## Git hooks

The hooks in [`hooks/`](./hooks) run in every repository on the machine, or only in the repositories you choose.

### Setup

Both options set `core.hooksPath`. A repository's local value overrides the global one.

| Option | Script | Where the setting goes |
|---|---|---|
| Every repository | [`scripts/configure-global-git-hooks.sh`](./scripts/configure-global-git-hooks.sh) | Global Git config: `core.hooksPath = ~/.dotfiles/hooks` |
| One repository | [`scripts/configure-local-git-hooks.sh [repository-path]`](./scripts/configure-local-git-hooks.sh) | That repository's `.git/config` |

`~/.gitconfig` links to `home/.gitconfig`, which already contains the global setting.
A machine that links `home/.gitconfig` gets the hooks in every repository.
To use only the local option, remove `hooksPath` from `home/.gitconfig` on that machine.

`configure-local-git-hooks.sh` uses the current directory if you pass no path.
It does not replace an existing local `core.hooksPath`, such as one set by Husky,
because that turns off the other tool's hooks.
It prints the command to replace it anyway.
To undo it, run `git config --unset core.hooksPath` in the repository.

A repository with its own local `core.hooksPath` ignores the global hooks.

### Turn the hooks off in one repository

With the global option, run this in the repository:

```bash
git config core.hooksPath .git/hooks
```

Git then runs only the repository's own hooks from `.git/hooks`.
To turn the global hooks back on, run `git config --unset core.hooksPath`.

### Hooks

Each file in `hooks/` only calls the script with its name in `scripts/`, passing on its arguments and stdin.
The script holds all the logic.

| Hook | Git runs it | Script | What the script runs | Can block |
|---|---|---|---|---|
| `pre-commit` | Before a commit | [`pre-commit.sh`](./scripts/pre-commit.sh) | The checks below | Yes |
| `pre-push` | Before a push | [`pre-push.sh`](./scripts/pre-push.sh) | [`detect-push-without-tests.sh`](./scripts/detect-push-without-tests.sh) | Yes |
| `post-merge` | After a merge or a fast-forward pull | [`post-merge.sh`](./scripts/post-merge.sh) | [`install-dependencies-on-change.sh`](./scripts/install-dependencies-on-change.sh) | No |
| `post-rewrite` | After a rebase or `commit --amend` | [`post-rewrite.sh`](./scripts/post-rewrite.sh) | `install-dependencies-on-change.sh`, on rebase only | No |

`scripts/pre-commit.sh` runs three checks:

1. [`detect-commit-without-tests.sh`](./scripts/detect-commit-without-tests.sh) rejects a commit that changes
   JS/TS or Elixir source files without a test file.
2. [`generate-markdown-toc.sh`](./scripts/generate-markdown-toc.sh) updates the doctoc table of contents
   in staged Markdown files and stages the result. It decodes percent-encoded anchors (`#d%C3%ADa` to `#día`),
   because rumdl only accepts the decoded form.
3. [`check-markdown.sh --staged`](./scripts/check-markdown.sh) runs rumdl and Vale on staged Markdown files.
   rumdl fixes what it can and stages the fixes. Vale only reports: it blocks the commit only when it cannot run.
   Vale uses the repository's `.vale.ini` if present, otherwise [`config/vale/.vale.ini`](./config/vale/.vale.ini).

`install-dependencies-on-change.sh` compares the commit before the pull with `HEAD`
and runs one command per changed dependency file:

| Changed file | Command |
|---|---|
| `pyproject.toml`, `poetry.lock` | `make build` |
| `package.json`, `yarn.lock` | `yarn install` if `yarn.lock` exists, otherwise `npm install`; then `npm run build` |
| `mix.exs`, `mix.lock` | `mix deps.get && mix compile` |
| `.tool-versions` | `asdf install`, then the Elixir setup steps from the stonehenge workflow |

These commands come from the repository you pull.
A pull in an untrusted repository runs that repository's build and install scripts.

With `pull.rebase = true`, a pull without local commits runs `post-merge`.
A pull with local commits rebases them and runs `post-rewrite` instead.
Both run the same dependency check.

### Repository hooks

Git skips `.git/hooks` when `core.hooksPath` has a value.
Each hook script calls [`scripts/run-local-git-hook.sh`](./scripts/run-local-git-hook.sh) at the end,
which runs the repository's own hook of the same name, if present.
This covers `pre-commit`, `pre-push`, `post-merge` and `post-rewrite` only.
Other hooks in `.git/hooks`, such as `commit-msg`, do not run.

### Requirements

- Markdown checks: [rumdl](https://github.com/rvben/rumdl), [Vale](https://vale.sh/) and
  [doctoc](https://www.npmjs.com/package/doctoc) (`npm install --global doctoc`).
  Download the Vale styles once with `vale sync --config ~/.dotfiles/config/vale/.vale.ini`.
  Spell checking accepts English and Spanish. The Spanish dictionary lives in
  [`config/vale/styles/config/dictionaries`](./config/vale/styles/config/dictionaries), so it needs no extra install.
  It comes from the LibreOffice dictionaries (Debian package `hunspell-es`), tri-licensed under GPL, LGPL and MPL.
- Dependency check: the tools of each project, such as `make`, `npm`, `yarn`, `mix` and `asdf`.

### Skip the hooks

- One commit or push: `git commit --no-verify`, `git push --no-verify`.
- One pull: `git -c core.hooksPath=/dev/null pull`.

## Interesting tools

### OSX

- <https://github.com/chipsenkbeil/choose>
- <https://www.macbartender.com/>
- <https://bjango.com/mac/istatmenus/>
- <https://apps.apple.com/us/app/dato/id1470584107?mt=12>
- Tiling manager: <https://github.com/koekeishiya/yabai>

### Linux

- <https://github.com/davatorium/rofi>
- Tiling manager: <https://i3wm.org/>
- <https://dwm.suckless.org/>

## IntelliJ settings

- I'm using the "IDE Settings Sync" plugin, which syncs the IDE settings on every instance where I'm logged in.
- Still, the exported settings are included in this repo as a ZIP file

## How to set up my Stream Deck Mini

- [elgato Stream Deck Mini](https://www.elgato.com/us/en/p/stream-deck-mini)
- <https://help.elgato.com/hc/en-us/articles/360028232451-Elgato-Stream-Deck-Plugins>
- App: [StreamController](https://streamcontroller.github.io/docs/latest/), installed with Flatpak
- Run `install_elgato_stream_deck.sh`. It installs StreamController, adds the udev rule for the
  device and restores the pages from `apps/streamcontroller/` if StreamController has none.
- On GNOME, the script also sets up automatic page switching by window: it sets
  `XDG_CURRENT_DESKTOP=GNOME` for the Flatpak and requests the StreamController GNOME extension.
  Approve the GNOME dialog, then restart StreamController.
- In StreamController, open the menu > Open Store and install what the pages use:
  - Plugins: OS, Deck, OBS, Clocks, Weather, Battery and Speedtest.
  - Icon packs: Material Icons and Bootstrap Icons. The pages refer to these icons, and
    `export_apps.sh` does not export them.
- In Settings > Plugins > OBS, enter the OBS WebSocket password.
- The OBS buttons run `obs-ctl` (`scripts/obs-ctl`), linked into `~/.local/bin` by `install-home-files.sh`.
- `export_apps.sh` exports the current pages to `apps/streamcontroller/`.
- StreamController adds its own autostart entry.
- Google Meet controls: [streamdeck-googlemeet](https://github.com/ChrisRegado/streamdeck-googlemeet).
  - Version 1.6.3. The [release page](https://github.com/ChrisRegado/streamdeck-googlemeet/releases/tag/v1.6.3)
    has the Chrome extension, the Firefox extension and the Stream Deck plugin.
  - The browser extension connects to the plugin on `ws://127.0.0.1:2394`.
  - The plugin runs in [OpenDeck](https://github.com/nekename/OpenDeck), which runs Elgato Stream Deck plugins on Linux.
    OpenDeck installs it as `~/.config/opendeck/plugins/com.chrisregado.googlemeet.sdPlugin`.
  - Chrome loads the extension unpacked from [`apps/chrome-extension-v1.6.3`](./apps/chrome-extension-v1.6.3).
    Do not move or delete this folder. Chrome does not keep its own copy.
  - Firefox installs the extension from the `.xpi` file and keeps its own copy in the profile.
- Icons:
  - <https://www.flaticon.com/authors/anggara/color-lineal-color?author_id=1427&type=standard>
  - <https://www.dropbox.com/s/a1zt9q4tv47sam4/72.zip?dl=0>

### ydotool

- `xdotool` does not work from Ubuntu 22.04 (because of the migration from Xorg to Wayland)
- Some alternatives: `dotool` and `ydotool`
  - <https://github.com/ReimuNotMoe/ydotool>
  - <https://gabrielstaples.com/ydotool-tutorial/#gsc.tab=0>
  - <https://github.com/torvalds/linux/blob/master/include/uapi/linux/input-event-codes.h>  

## Wacom tablet

- Model: [One by Wacom, model CTL-672](https://estore.wacom.com/en-de/one-by-wacom-medium-s-ctl-672-s.html)
  - <https://www.wacom.com/en-us/getting-started/one-by-wacom>
- Unpack One by Wacom: <https://www.youtube.com/watch?v=GRjwkf0Qbg4>
- <https://www.wacom.com/en-es/about-wacom/news-and-events/2020/1436>

### Installation

- <https://linuxwacom.github.io/>
- <https://help.ubuntu.com/stable/ubuntu-help/wacom.html.en>
- <https://github.com/linuxwacom>

### Software

- OpenBoard: <https://www.youtube.com/watch?v=4znZqySzUoQ>
- Limnu
- Pear Deck
- Kami (web)
- Collaboard (web)
- Explain everything (web)

### OpenBoard installation

- `sudo apt install onboard`
- `sudo apt --fix-broken install`
- <https://github.com/OpenBoard-org/OpenBoard/releases/download/v1.6.1/openboard_ubuntu_20.04_1.6.1_amd64.deb>
- `sudo dpkg -i openboard_ubuntu_20.04_1.6.1_amd64.deb`
