#!/usr/bin/env bash
set -euo pipefail

DOTFILES_PATH="${DOTFILES_PATH:-$HOME/.dotfiles}"
STREAMCONTROLLER_ID="com.core447.StreamController"
STREAMCONTROLLER_DATA="$HOME/.var/app/$STREAMCONTROLLER_ID/data"
STREAMCONTROLLER_EXPORT="$DOTFILES_PATH/apps/streamcontroller"
UDEV_RULES_FILE="/etc/udev/rules.d/70-streamdeck.rules"
UDEV_RULE='SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", TAG+="uaccess"'
GNOME_EXTENSION_UUID="streamcontroller@core447.com"

main() {
	install_streamcontroller
	allow_stream_deck_access
	restore_streamcontroller_config
	if [[ "${XDG_CURRENT_DESKTOP:-}" == *GNOME* ]]; then
		enable_window_detection_on_gnome
		install_gnome_extension
	fi

	echo "And... DONE! Next steps in StreamController:"
	echo "  1. Menu > Open Store: install the OS, Deck, OBS, Clocks, Weather, Battery and Speedtest plugins,"
	echo "     and the Material Icons and Bootstrap Icons icon packs"
	echo "  2. Settings > Plugins > OBS: enter your OBS WebSocket password"
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

# StreamController detects the active window (for automatic page switching) only when
# XDG_CURRENT_DESKTOP is exactly "GNOME". Ubuntu sets it to "ubuntu:GNOME".
enable_window_detection_on_gnome() {
	flatpak override --user --env=XDG_CURRENT_DESKTOP=GNOME "$STREAMCONTROLLER_ID"
	echo "StreamController Flatpak override:"
	flatpak override --user --show "$STREAMCONTROLLER_ID"
}

# On Wayland, StreamController reads the active window through its GNOME Shell extension.
# GNOME shows a dialog to approve the installation from extensions.gnome.org.
install_gnome_extension() {
	if gnome-extensions info "$GNOME_EXTENSION_UUID" >/dev/null 2>&1; then
		echo "GNOME extension $GNOME_EXTENSION_UUID is already installed"
		return
	fi
	echo "Approve the installation of the StreamController GNOME extension in the dialog"
	# The helper process can quit before replying, even when the installation succeeds
	gdbus call --session --timeout 180 \
		--dest org.gnome.Shell.Extensions \
		--object-path /org/gnome/Shell/Extensions \
		--method org.gnome.Shell.Extensions.InstallRemoteExtension \
		"$GNOME_EXTENSION_UUID" >/dev/null 2>&1 || true
	if gnome-extensions info "$GNOME_EXTENSION_UUID" >/dev/null 2>&1; then
		echo "GNOME extension $GNOME_EXTENSION_UUID installed. Restart StreamController to use it."
	else
		printf 'GNOME extension %s is not installed. Install it from extensions.gnome.org\n' \
			"$GNOME_EXTENSION_UUID" >&2
	fi
}

main
