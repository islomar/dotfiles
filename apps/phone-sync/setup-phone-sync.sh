#!/bin/bash
#
# Sets up the PC side of the phone photo sync: GSConnect, Syncthing (receive-only folders), firewall rules
# and the daily backup timer. Safe to re-run. See README.md in this folder for the phone side.
#
# Usage:
#   setup-phone-sync.sh setup [phone-device-id]   Install and configure everything (asks for sudo once)
#   setup-phone-sync.sh doctor                    Show the state of every part
#
# The phone's Syncthing device ID, the GUI password and the PC's Syncthing identity (cert.pem, key.pem)
# come from 1Password. Pass the device ID as an argument when 1Password is not available.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OP_VAULT="Personal"
OP_ITEM="Syncthing GUI (Ubuntu PC)"
OP_CERT_DOC="Syncthing PC identity cert.pem (Ubuntu PC)"
OP_KEY_DOC="Syncthing PC identity key.pem (Ubuntu PC)"

GSCONNECT_UUID="gsconnect@andyholmes.github.io"
GSCONNECT_DCONF="/org/gnome/shell/extensions/gsconnect"
APT_PACKAGES=(sshfs python3-nautilus syncthing rsync)

SYNCTHING_STATE="$HOME/.local/state/syncthing"
GUI_USER="islomar"
PHONE_NAME="Fairphone 6"
PHONE_ROOT="$HOME/Pictures/Phone"
BACKUP_DIR="/mnt/data/phone-backup"
UNIT_DIR="$HOME/.config/systemd/user"
UNITS=(phone-photos-backup.service phone-photos-backup.timer)

# Folder IDs must match the folders shared from Syncthing-Fork on the phone.
# Format: id|label|subfolder of PHONE_ROOT
FOLDERS=(
	"lx275-06ulv|Phone Camera|Camera"
	"hokzg-fgwdm|Phone DCIM|DCIM"
	"urlkm-15fxo|Phone Pictures|Pictures"
	"4vvc4-tx4sw|Phone WhatsApp Images|WhatsApp"
	"t4956-okmrh|Phone Telegram Images|Telegram"
)
# DCIM/Camera arrives through its own folder. Ignore it in DCIM so it is not copied twice.
DCIM_FOLDER_ID="hokzg-fgwdm"
DCIM_IGNORE="/Camera"

main() {
	case "${1:-}" in
	setup) setup "${2:-}" ;;
	doctor) doctor ;;
	*)
		sed -n '6,8p' "$0" | sed 's/^# \{0,1\}//' >&2
		exit 1
		;;
	esac
}

setup() {
	local phone_id="$1"
	[[ -n "$phone_id" ]] || phone_id="$(op_field "Phone device ID" | cut -d' ' -f1)"
	[[ -n "$phone_id" ]] || die "No phone device ID. Pass it as an argument or sign in to 1Password."

	install_packages
	open_firewall
	setup_gsconnect
	restore_syncthing_identity
	start_syncthing
	set_gui_password
	add_phone_device "$phone_id"
	add_folders "$phone_id"
	install_backup_timer
	echo
	echo "Done. Run '$0 doctor' to check. Phone steps: see README.md."
}

install_packages() {
	local missing=()
	for pkg in "${APT_PACKAGES[@]}"; do
		dpkg -s "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
	done
	if ((${#missing[@]})); then
		step "Installing ${missing[*]}"
		sudo apt-get install -y "${missing[@]}"
	fi
}

open_firewall() {
	step "Firewall rules (applied when ufw is enabled)"
	sudo ufw allow 1714:1764/udp comment 'GSConnect'
	sudo ufw allow 1714:1764/tcp comment 'GSConnect'
	sudo ufw allow 22000/tcp comment 'Syncthing'
	sudo ufw allow 22000/udp comment 'Syncthing'
	sudo ufw allow 21027/udp comment 'Syncthing discovery'
}

setup_gsconnect() {
	step "GSConnect"
	if ! gnome-extensions info "$GSCONNECT_UUID" >/dev/null 2>&1; then
		sudo apt-get install -y gnome-shell-extension-gsconnect
		echo "GSConnect installed. Log out and in, then re-run this script."
	fi
	gnome-extensions enable "$GSCONNECT_UUID" 2>/dev/null || true
	dconf write "$GSCONNECT_DCONF/discoverable" true
}

restore_syncthing_identity() {
	step "Syncthing identity"
	if [[ -f "$SYNCTHING_STATE/key.pem" ]]; then
		echo "Keeping existing identity in $SYNCTHING_STATE"
		return
	fi
	if ! command -v op >/dev/null; then
		echo "1Password CLI missing: Syncthing creates a new identity. Re-add the PC on the phone."
		return
	fi
	mkdir -p "$SYNCTHING_STATE"
	op document get "$OP_CERT_DOC" --vault "$OP_VAULT" --out-file "$SYNCTHING_STATE/cert.pem"
	op document get "$OP_KEY_DOC" --vault "$OP_VAULT" --out-file "$SYNCTHING_STATE/key.pem"
	chmod 600 "$SYNCTHING_STATE/key.pem"
}

start_syncthing() {
	step "Syncthing service"
	systemctl --user enable --now syncthing.service
	for _ in $(seq 1 30); do
		syncthing cli show system >/dev/null 2>&1 && return
		sleep 1
	done
	die "Syncthing API did not start"
}

set_gui_password() {
	local password
	password="$(op_field password)"
	if [[ -z "$password" ]]; then
		echo "No GUI password from 1Password. Set one at http://127.0.0.1:8384."
		return
	fi
	syncthing cli config gui user set "$GUI_USER"
	# Keep the password and the API key out of process arguments: the body comes from stdin
	# and the header from a pipe. Syncthing stores the bcrypt hash of a plain-text password.
	local api_key
	api_key="$(syncthing cli config gui apikey get)"
	PASSWORD="$password" python3 -c 'import json,os; print(json.dumps({"password": os.environ["PASSWORD"]}))' |
		curl -sf -X PATCH -H @<(printf 'X-API-Key: %s\n' "$api_key") \
			-H 'Content-Type: application/json' --data-binary @- \
			http://127.0.0.1:8384/rest/config/gui >/dev/null
}

add_phone_device() {
	local phone_id="$1"
	step "Phone device"
	if syncthing cli config devices list | grep -qx "$phone_id"; then
		echo "Already added"
		return
	fi
	syncthing cli config devices add --device-id "$phone_id" --name "$PHONE_NAME"
}

add_folders() {
	local phone_id="$1" entry id label subdir path existing
	step "Folders (receive only, ignore delete)"
	existing="$(syncthing cli config folders list)"
	for entry in "${FOLDERS[@]}"; do
		IFS='|' read -r id label subdir <<<"$entry"
		path="$PHONE_ROOT/$subdir"
		if grep -qx "$id" <<<"$existing"; then
			echo "$label: already added"
			continue
		fi
		mkdir -p "$path"
		[[ "$id" == "$DCIM_FOLDER_ID" ]] && printf '%s\n' "$DCIM_IGNORE" >"$path/.stignore"
		syncthing cli config folders add --id "$id" --label "$label" --path "$path" --type receiveonly --paused
		syncthing cli config folders "$id" devices add --device-id "$phone_id"
		syncthing cli config folders "$id" ignore-delete set true
		syncthing cli config folders "$id" paused set false
		echo "$label: added"
	done
}

install_backup_timer() {
	step "Backup timer"
	[[ -d "$BACKUP_DIR" ]] || echo "Warning: $BACKUP_DIR does not exist. The timer skips runs until it does."
	mkdir -p "$UNIT_DIR"
	for unit in "${UNITS[@]}"; do
		cp "$SCRIPT_DIR/$unit" "$UNIT_DIR/$unit"
	done
	systemctl --user daemon-reload
	systemctl --user enable --now phone-photos-backup.timer
}

doctor() {
	local phone_id
	step "Packages"
	for pkg in "${APT_PACKAGES[@]}"; do
		dpkg -s "$pkg" >/dev/null 2>&1 && echo "OK      $pkg" || echo "MISSING $pkg"
	done

	step "GSConnect"
	gnome-extensions info "$GSCONNECT_UUID" 2>/dev/null | grep -E 'Version|State' || echo "MISSING extension"
	echo "discoverable: $(dconf read "$GSCONNECT_DCONF/discoverable")"

	step "Syncthing"
	echo "service: $(systemctl --user is-active syncthing.service)"
	echo "device ID: $(syncthing cli show system | python3 -c 'import sys,json;print(json.load(sys.stdin)["myID"])')"
	phone_id="$(syncthing cli config devices list | grep -v "$(syncthing cli show system | python3 -c 'import sys,json;print(json.load(sys.stdin)["myID"])')" | head -1)"
	syncthing cli show connections | python3 -c "
import sys, json
c = json.load(sys.stdin)['connections'].get('$phone_id', {})
print('phone connected:', c.get('connected', False))"
	local api_key entry id label subdir
	api_key="$(syncthing cli config gui apikey get)"
	for entry in "${FOLDERS[@]}"; do
		IFS='|' read -r id label subdir <<<"$entry"
		curl -s -H "X-API-Key: $api_key" "http://127.0.0.1:8384/rest/db/status?folder=$id" |
			python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(f\"{'$label':24} {d['state']:8} files {d['localFiles']}/{d['globalFiles']} need {d['needFiles']} errors {d.get('errors', 0)}\")
except Exception:
    print('$label: MISSING')"
	done

	step "Backup"
	systemctl --user list-timers phone-photos-backup.timer --no-pager | head -2
	echo "last run: $(systemctl --user show phone-photos-backup.service -p Result --value)"
}

# Prints the raw value of one field of the 1Password item. Plain --fields output adds CSV quotes.
op_field() {
	command -v op >/dev/null || return 0
	op item get "$OP_ITEM" --vault "$OP_VAULT" --fields "label=$1" --reveal --format json 2>/dev/null |
		python3 -c 'import sys,json; print(json.load(sys.stdin).get("value", ""))' 2>/dev/null || true
}


step() { printf '\n== %s\n' "$1"; }
die() {
	echo "Error: $1" >&2
	exit 1
}

main "$@"
