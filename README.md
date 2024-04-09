# dotfiles
All general purpose dot files with preferences and settings.

`git clone git@github.com:islomar/dotfiles.git ~/.dotfiles`

Some references used:

* [CodelyTV](https://github.com/CodelyTV/dotfiles)
* https://dotfiles.github.io/
* https://github.com/marianudo/dotfiles
* https://github.com/google/styleguide/blob/gh-pages/intellij-java-google-style.xml

## OS setups
* [Ubuntu](./install_ubuntu_apps.sh)
  * scripts/install-home-files.sh
* [OSX](./install_osx_apps.sh)
* Common: 
  * [Install scripts](./install_scripts.sh)

## Interesting tools
### OSX
* https://github.com/chipsenkbeil/choose
* https://www.macbartender.com/
* https://bjango.com/mac/istatmenus/
* https://apps.apple.com/us/app/dato/id1470584107?mt=12
* Tiling manager: https://github.com/koekeishiya/yabai


### Linux
* https://github.com/davatorium/rofi
* Tiling manager: https://i3wm.org/
* https://dwm.suckless.org/

## IntelliJ settings
* I'm using the "IDE Settings Sync" plugin, which is an automated way of syncing the IDE on any instance where you have logged.
* Still, the exported settings are included in this repo as a ZIP file

## How to set up my Stream Deck Mini
- [elgato Stream Deck Mini](https://www.elgato.com/us/en/p/stream-deck-mini)
- https://help.elgato.com/hc/en-us/articles/360028232451-Elgato-Stream-Deck-Plugins
- Run `install_elgato_stream_deck.sh`
- https://timothycrosley.github.io/streamdeck-ui/ >> Great EXAMPLES
  - Fork more up-to-date: https://github.com/streamdeck-linux-gui/streamdeck-linux-gui
- https://onlinux.systems/guides/20220323_how-to-set-up-elgatos-stream-deck-on-ubuntu-linux-2110/
- Icons:
  - https://www.flaticon.com/authors/anggara/color-lineal-color?author_id=1427&type=standard 
  - https://www.dropbox.com/s/a1zt9q4tv47sam4/72.zip?dl=0
- "Startup Application Preferences"
  - Name: Stream Deck
  - Command: streamdeck &

### ydotool
- `xdotool` does not work from Ubuntu 22.04 (because of the migration from Xorg to Wayland)
- Some alternatives: `dotool` and `ydotool`
  - https://github.com/ReimuNotMoe/ydotool
  - https://gabrielstaples.com/ydotool-tutorial/#gsc.tab=0
  - https://github.com/torvalds/linux/blob/master/include/uapi/linux/input-event-codes.h  

## Wacom tablet
- Model: [One by Wacom, model CTL-672](https://estore.wacom.com/en-de/one-by-wacom-medium-s-ctl-672-s.html)
  - https://www.wacom.com/en-us/getting-started/one-by-wacom
- Unpack One by Wacom: https://www.youtube.com/watch?v=GRjwkf0Qbg4
- https://www.wacom.com/en-es/about-wacom/news-and-events/2020/1436

### Installation
- https://linuxwacom.github.io/
- https://help.ubuntu.com/stable/ubuntu-help/wacom.html.en
- https://github.com/linuxwacom

### Software
- OpenBoard: https://www.youtube.com/watch?v=4znZqySzUoQ
- Limnu
- Pear Deck
- Kami (web)
- Collaboard (web)
- Explain everything (web)

### OpenBoard installation
- `sudo apt install onboard`
- `sudo apt --fix-broken install`
- https://github.com/OpenBoard-org/OpenBoard/releases/download/v1.6.1/openboard_ubuntu_20.04_1.6.1_amd64.deb
- `sudo dpkg -i openboard_ubuntu_20.04_1.6.1_amd64.deb`