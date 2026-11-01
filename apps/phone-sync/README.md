<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents** *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Phone photo sync: Fairphone 6 to Ubuntu](#phone-photo-sync-fairphone-6-to-ubuntu)
  - [Files](#files)
  - [What runs where](#what-runs-where)
    - [PC](#pc)
    - [Syncthing folders](#syncthing-folders)
    - [1Password, vault `Personal`](#1password-vault-personal)
  - [Set up the PC](#set-up-the-pc)
  - [Set up the phone](#set-up-the-phone)
    - [KDE Connect](#kde-connect)
    - [Syncthing-Fork](#syncthing-fork)
    - [Telegram](#telegram)
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

Backup target: `/mnt/data/phone-backup/`, same subfolders.

### 1Password, vault `Personal`

| Item | Content |
|---|---|
| `Syncthing GUI (Ubuntu PC)` | GUI login, URL, PC and phone device IDs, folder notes |
| `Syncthing PC identity cert.pem (Ubuntu PC)` | PC Syncthing certificate |
| `Syncthing PC identity key.pem (Ubuntu PC)` | PC Syncthing private key |

The script restores `cert.pem` and `key.pem` on a new install.
The PC keeps its device ID, and the phone reconnects without changes.

## Set up the PC

1. Sign in to the 1Password CLI: `op vault list` must work.
2. Run `./setup-phone-sync.sh setup`. It asks for `sudo` for apt and ufw.
3. Run `./setup-phone-sync.sh doctor`. The phone shows `connected: True` when both devices share the Wi-Fi.

Without 1Password, pass the phone device ID: `./setup-phone-sync.sh setup <device-id>`.
Syncthing then creates a new identity, and the phone needs the new PC device ID.

## Set up the phone

The phone is in Spanish. Labels below are the Spanish ones.

### KDE Connect

1. Install KDE Connect. Pair with the PC `executive`.
2. Open the device, ⋮, Configuración de complementos.
3. Turn on Exponer el sistema de archivos and add `DCIM` and `Pictures`.

### Syncthing-Fork

1. Install Syncthing-Fork.
2. Grant all-files access: Ajustes, Aplicaciones, Syncthing-Fork, Permisos, Archivos y contenido multimedia, Permitir la gestión de todos los archivos.
3. Set battery to Sin restricciones.
4. Add the PC device ID from 1Password.
5. Add the four folders from the table above, type Solo enviar, shared with the PC.
   The folder picker cannot open `Android/media`.
   For WhatsApp and Telegram, use ☰, Interfaz web, Agregar carpeta, and type the full path.
   On a new phone, Syncthing-Fork creates new folder IDs. Change the IDs in the web interface to the ones above, or update `FOLDERS` in the script.

### Telegram

Telegram keeps received images in `Android/data`, which no other app can read on Android 11 and later.
Turn on Ajustes, Datos y almacenamiento, Guardar en Galería, for private chats only. Groups and channels add noise.
Images saved before that stay only in Telegram's cloud.

## Daily use

- Browse the phone: Quick Settings, The Fairphone Gen 6, folder icon. Nautilus shows the phone's LAN address in the sidebar. Open `storage/emulated/0`.
- Free space on the phone: delete photos on the phone. The PC copy stays.
- Do not click Revert Local Changes in the Syncthing GUI. It downloads moved photos again.

## Limits

- The backup is on `nvme0n1p3`, the same SSD as `/home`. It protects against deletion, not against disk failure.
- The Homebrew `gio` in `PATH` has no gvfs support. Use `/usr/bin/gio` for `sftp://` paths.
- Docker ports skip ufw. The compose files of PostgreSQL and MariaDB in two course repositories now bind to `127.0.0.1`.
  Those edits live uncommitted in the course repositories. This script does not cover them.

## Troubleshooting

| Symptom | Check |
|---|---|
| Phone does not see the PC in KDE Connect | `dconf read /org/gnome/shell/extensions/gsconnect/discoverable` must be `true`. Add the PC by IP in the app |
| Mount fails with `Connection failed` | No folder in Exponer el sistema de archivos. Ports 1739-1764 on the phone stay closed until you add one |
| A folder stays `syncing` | Syncthing-Fork stopped by battery saving. Check Sin restricciones |
| Timer fails | `/mnt/data` not mounted. `journalctl --user -u phone-photos-backup.service` |
