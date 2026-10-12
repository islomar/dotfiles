<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Contents

- [dotfiles](#dotfiles)
  - [OS setups](#os-setups)
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
- In StreamController, open the menu > Open Store and install the OS, Deck and OBS plugins.
- In Settings > Plugins > OBS, enter the OBS WebSocket password.
- The OBS buttons run `obs-ctl` (`scripts/obs-ctl`), linked into `~/.local/bin` by `install-home-files.sh`.
- `export_apps.sh` exports the current pages to `apps/streamcontroller/`.
- StreamController adds its own autostart entry.
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
