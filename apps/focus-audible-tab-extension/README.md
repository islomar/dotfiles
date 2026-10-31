<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents** *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Focus Audible Tab](#focus-audible-tab)
  - [Why an extension](#why-an-extension)
  - [Files](#files)
  - [How the cycling works](#how-the-cycling-works)
  - [Install](#install)
    - [Chrome](#chrome)
    - [Firefox](#firefox)
  - [Shortcut](#shortcut)
  - [Stream Deck](#stream-deck)
  - [Known limits](#known-limits)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Focus Audible Tab

A browser extension for Chrome and Firefox. A keyboard shortcut switches to the tab that plays sound.
If more than one tab plays sound, each press moves to the next one and wraps around at the end.

Created with Claude Code, session `3bb9b5d6-347d-4179-85bd-08ed2c75bf94`.
To continue that session from the dotfiles root: `claude --resume 3bb9b5d6-347d-4179-85bd-08ed2c75bf94`.

## Why an extension

GNOME runs on Wayland. On Wayland, `xdotool` and `wmctrl` cannot focus windows.
`pactl` lists audio streams per process. Chrome plays the audio of every tab from one process, so the
system cannot tell which tab plays sound. Only the browser knows, through `tabs.query({ audible: true })`.

## Files

| File | Purpose |
|---|---|
| `manifest.json` | Manifest V3. Declares the `tabs` permission and the `focus-next-audible-tab` command. |
| `background.js` | Handles the command. Chrome runs it as a service worker, Firefox as a background script. |

## How the cycling works

1. Get all audible tabs in all windows. Sort them by window, then by tab position.
2. Find the active tab of the last focused window in that list.
3. Switch to the next tab in the list and focus its window. If the active tab does not play sound, switch to the first one.

The extension stores no state. The active tab marks the position in the cycle.

Chrome reports a muted tab as audible while it plays. Such tabs are part of the cycle.

## Install

### Chrome

1. Open `chrome://extensions`.
2. Turn on **Developer mode**.
3. Click **Load unpacked** and select this folder.

Chrome shows the warning "'background.scripts' requires manifest version of 2 or lower." Ignore it.
Firefox needs `background.scripts`. Chrome uses `background.service_worker` and skips `scripts`.

Chrome loads the extension from this folder and keeps no copy. Do not move or delete the folder.
After you change the code, click the reload icon on the extension card.

### Firefox

1. Open `about:debugging#/runtime/this-firefox`.
2. Click **Load Temporary Add-on** and select `manifest.json` in this folder.

Firefox removes temporary add-ons when it restarts. Repeat these steps after each restart.
To keep it installed, sign it as an unlisted add-on with `web-ext sign` and a Mozilla add-ons API key.
Needs Firefox 121 or later.

## Shortcut

The default shortcut is `Alt+Shift+M`. The shortcut works only when the browser window has focus.
A browser does not apply a suggested shortcut that another extension already uses. In that case, set it by hand:

- Chrome: `chrome://extensions/shortcuts`
- Firefox: `about:addons` > gear icon > **Manage Extension Shortcuts**

## Stream Deck

In StreamController, add an OS plugin **Hotkey** action that sends `Alt+Shift+M`.
The key press goes to the focused window, so the browser must have focus.

## Known limits

- The shortcut does nothing when another app has focus.
  A desktop-wide trigger needs a channel from outside the browser into the extension. Two options:
  - Native messaging: a host program plus one host manifest per browser.
  - A local WebSocket, as `streamdeck-googlemeet` does (see the main README). The extension
    connects to a small server on `127.0.0.1`, and a Stream Deck button or GNOME shortcut sends it a message.
- When the next audible tab is in a different browser window, the extension asks the browser to focus that window.
  GNOME on Wayland can refuse focus requests and show a "window is ready" notification instead. Not tested yet.
- With two browsers open, each browser cycles only through its own tabs.
