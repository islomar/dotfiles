<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents** *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Phone photo sync: Fairphone 6 to Ubuntu](#phone-photo-sync-fairphone-6-to-ubuntu)
  - [Files](#files)
  - [What runs where](#what-runs-where)
    - [PC](#pc)
    - [Syncthing folders](#syncthing-folders)
    - [1Password](#1password)
  - [Daily use](#daily-use)
  - [Limits](#limits)
  - [Troubleshooting](#troubleshooting)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Phone photo sync: Fairphone 6 to Ubuntu

Wireless link between the phone (Android 16) and the PC (Ubuntu 26.04, GNOME 50).
KDE Connect browses and cleans up the phone from Nautilus.
Syncthing copies every photo to the PC.
A daily timer copies the PC folder to a second partition.

## Files

| File | Content |
|---|---|
| [`setup-phone-sync.sh`](./setup-phone-sync.sh) | PC setup, safe to re-run: `setup`, `doctor` |
| [`phone-photos-backup.service`](./phone-photos-backup.service) | `rsync` from `~/Pictures/Phone/` to the backup folder. Adds files, never deletes |
| [`phone-photos-backup.timer`](./phone-photos-backup.timer) | Runs the service daily and 15 minutes after login |

## What runs where

### PC

| Part | Configuration | Location |
|---|---|---|
| GSConnect 74 | GNOME extension, `discoverable = true` | `~/.local/share/gnome-shell/extensions/gsconnect@andyholmes.github.io`, dconf `/org/gnome/shell/extensions/gsconnect/` |
| `sshfs`, `python3-nautilus` | GSConnect mount and the Nautilus "Send to mobile" menu | apt |
| Syncthing 1.29 | User service, GUI on `127.0.0.1:8384` only | `~/.local/state/syncthing/`, `systemctl --user` |
| Backup | Daily `rsync` | `~/.config/systemd/user/phone-photos-backup.*` |
| ufw | Enabled. Allows GSConnect 1714-1764 tcp/udp, Syncthing 22000 tcp/udp and 21027 udp | `/etc/ufw/user.rules` |

### Syncthing folders

Every folder is Send Only on the phone, and Receive Only with Ignore Delete on the PC.
A photo deleted on the phone stays on the PC.

| Folder ID | Phone path, under `/storage/emulated/0/` | PC path, under `~/Pictures/Phone/` |
|---|---|---|
| `hokzg-fgwdm` | `DCIM`, including `Camera` | `DCIM` |
| `urlkm-15fxo` | `Pictures` | `Pictures` |
| `4vvc4-tx4sw` | `Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Images` | `WhatsApp` |
| `t4956-okmrh` | `Android/media/org.telegram.messenger/Telegram/Telegram Images` | `Telegram` |

WhatsApp videos are not synced.

Backup target: `BACKUP_DIR` in `~/.config/phone-sync/config`, same subfolders.
This file is not in the repository. Create it before `setup`, with one line: `BACKUP_DIR=<folder>`.

### 1Password

The GUI login, the device IDs and the PC Syncthing identity are in 1Password. The script names the items.

## Daily use

- Browse the phone: Quick Settings, The Fairphone Gen 6, folder icon. Nautilus shows the phone's LAN address in the sidebar. Open `storage/emulated/0`.
- Free space on the phone: delete photos on the phone. The PC copy stays.
- Do not click Revert Local Changes in the Syncthing GUI. It downloads moved photos again.

## Limits

- The backup is on `nvme0n1p3`, the same SSD as `/home`. It protects against deletion, not against disk failure.
- The Homebrew `gio` in `PATH` has no gvfs support. Use `/usr/bin/gio` for `sftp://` paths.
- Docker ports skip ufw. PostgreSQL and MariaDB in two CodelyTV course repositories bind to `127.0.0.1` through a `compose.override.yml` with `ports: !override`.
  Each repository lists that file in `.git/info/exclude`, so `git pull` never touches it. This script does not create it.

## Troubleshooting

| Symptom | Check |
|---|---|
| Phone does not see the PC in KDE Connect | `dconf read /org/gnome/shell/extensions/gsconnect/discoverable` must be `true`. Add the PC by IP in the app |
| Mount fails with `Connection failed` | No folder in Exponer el sistema de archivos. Ports 1739-1764 on the phone stay closed until you add one |
| A folder stays `syncing` | Syncthing-Fork stopped by battery saving. Check Sin restricciones |
| Timer fails | `/mnt/data` not mounted. `journalctl --user -u phone-photos-backup.service` |
