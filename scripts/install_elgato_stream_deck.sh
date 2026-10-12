#!/usr/bin/env bash
set -euo pipefail

DOTFILES_PATH="${DOTFILES_PATH:-$HOME/.dotfiles}"
STREAMCONTROLLER_ID="com.core447.StreamController"
STREAMCONTROLLER_DATA="$HOME/.var/app/$STREAMCONTROLLER_ID/data"
STREAMCONTROLLER_EXPORT="$DOTFILES_PATH/apps/streamcontroller"
UDEV_RULES_FILE="/etc/udev/rules.d/70-streamdeck.rules"
UDEV_RULE='SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", TAG+="uaccess"'

main() {
	install_streamcontroller
	allow_stream_deck_access
	restore_streamcontroller_config

	echo "And... DONE! Next steps in StreamController:"
	echo "  1. Menu > Open Store: install the OS, Deck and OBS plugins"
	echo "  2. Replace OBS_WEBSOCKET_PASSWORD in the OBS buttons with your OBS WebSocket password"
}

install_streamcontroller() {
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	flatpak install -y flathub "$STREAMCONTROLLER_ID"
}

# Lets the logged-in user access Elgato (vendor 0fd9) USB devices without root
allow_stream_deck_access() {
	if [[ ! -d "$(dirname "$UDEV_RULES_FILE")" ]]; then
		printf 'Missing directory: %s. Is udev installed?\n' "$(dirname "$UDEV_RULES_FILE")" >&2
		exit 1
	fi
	if [[ -f "$UDEV_RULES_FILE" ]]; then
		sudo cp -p "$UDEV_RULES_FILE" "$UDEV_RULES_FILE.bak"
	fi
	echo "$UDEV_RULE" | sudo tee "$UDEV_RULES_FILE" >/dev/null
	sudo udevadm control --reload-rules
	sudo udevadm trigger
	echo "udev rule in $UDEV_RULES_FILE:"
	cat "$UDEV_RULES_FILE"
}

restore_streamcontroller_config() {
	if compgen -G "$STREAMCONTROLLER_DATA/pages/*.json" >/dev/null; then
		echo "StreamController already has pages, not restoring them from $STREAMCONTROLLER_EXPORT"
		return
	fi
	mkdir -p "$STREAMCONTROLLER_DATA"
	cp -pr "$STREAMCONTROLLER_EXPORT/." "$STREAMCONTROLLER_DATA/"
	echo "StreamController pages restored"
}

main
