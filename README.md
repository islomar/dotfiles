<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Contents

- [dotfiles](#dotfiles)
  - [OS setups](#os-setups)
  - [Git hooks](#git-hooks)
    - [Setup](#setup)
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

The hooks in [`hooks/`](./hooks) run in every Git repository on the machine.

### Setup

Run [`scripts/configure-global-git-hooks.sh`](./scripts/configure-global-git-hooks.sh).
It sets `core.hooksPath = ~/.dotfiles/hooks` in the global Git config.
`~/.gitconfig` links to `home/.gitconfig`, so the setting is also tracked in this repo.

A repository with its own local `core.hooksPath` (for example, one set up by Husky) ignores these hooks.

### Hooks

| Hook | Git runs it | What it runs | Can block |
|---|---|---|---|
| `pre-commit` | Before a commit | [`scripts/pre-commit.sh`](./scripts/pre-commit.sh) | Yes |
| `pre-push` | Before a push | [`scripts/detect-push-without-tests.sh`](./scripts/detect-push-without-tests.sh) | Yes |
| `post-merge` | After a merge or a fast-forward pull | [`scripts/install-dependencies-on-change.sh`](./scripts/install-dependencies-on-change.sh) | No |
| `post-rewrite` | After a rebase or `commit --amend` | `install-dependencies-on-change.sh`, on rebase only | No |

`scripts/pre-commit.sh` runs three checks:

1. [`detect-commit-without-tests.sh`](./scripts/detect-commit-without-tests.sh) rejects a commit that changes
   JS/TS or Elixir source files without a test file.
2. [`generate-markdown-toc.sh`](./scripts/generate-markdown-toc.sh) updates the doctoc table of contents
   in staged Markdown files and stages the result.
3. [`check-markdown.sh --staged`](./scripts/check-markdown.sh) runs rumdl and Vale on staged Markdown files.
   rumdl fixes what it can and stages the fixes. Vale only reports.
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
Each hook in `hooks/` calls [`scripts/run-local-hook.sh`](./scripts/run-local-hook.sh) at the end,
which runs the repository's own hook of the same name, if present.
This covers `pre-commit`, `pre-push`, `post-merge` and `post-rewrite` only.
Other hooks in `.git/hooks`, such as `commit-msg`, do not run.

### Requirements

- Markdown checks: [rumdl](https://github.com/rvben/rumdl), [Vale](https://vale.sh/) and
  [doctoc](https://www.npmjs.com/package/doctoc) (`npm install --global doctoc`).
  Download the Vale styles once with `vale sync --config ~/.dotfiles/config/vale/.vale.ini`.
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
  - Browser extension, version 1.6.3: Chrome and Firefox builds on the
    [release page](https://github.com/ChrisRegado/streamdeck-googlemeet/releases/tag/v1.6.3).
  - The extension connects to a Stream Deck plugin on `ws://127.0.0.1:2394`.
    The project ships that plugin for the Elgato Stream Deck software, not for StreamController.
    Without a program listening on that port, the extension does nothing.
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
