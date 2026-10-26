#!/bin/bash
#
# Sets up and checks the Tasker + Health Connect step automation on an Android phone over ADB.
# See README.md in this folder for the full procedure and the steps that need the phone's screen.
#
# Usage:
#   tasker-phone.sh setup       Install the plugin, grant permissions, exempt Tasker from Doze, push backup.xml
#   tasker-phone.sh doctor      Show versions, permissions, battery state and the last task runs
#   tasker-phone.sh runlog [n]  Show the last n Tasker run log lines for the step tasks (default 30)
#   tasker-phone.sh inventory   Show the result of the "Inventario pasos" task after running it on the phone
#
set -euo pipefail

TASKER_PACKAGE="net.dinglisch.android.taskerm"
PLUGIN_PACKAGE="com.rafapps.taskerhealthconnect"
PLUGIN_VERSION="1.0.4"
PLUGIN_URL="https://github.com/RafhaanShah/TaskerHealthConnect/releases/download/${PLUGIN_VERSION}/TaskerHealthConnect-${PLUGIN_VERSION}.apk"
PLUGIN_SHA256="aacb72354cca0fa5479874e47c331f8dadf466e8b0d5a69975ff9277623b681f"
HEALTH_PERMISSIONS=(
	android.permission.health.WRITE_STEPS
	android.permission.health.READ_STEPS
)
PHONE_BACKUP="/sdcard/Tasker/configs/user/backup.xml"
PHONE_RUNLOG="/sdcard/Tasker/log/runlog.txt"
PHONE_INVENTORY="/sdcard/Download/pasos_inventario.txt"

main() {
	require_command "adb" "sudo apt install adb android-sdk-platform-tools-common"
	require_device

	case "${1:-}" in
	setup) setup ;;
	doctor) doctor ;;
	runlog) show_runlog "${2:-30}" ;;
	inventory) show_inventory ;;
	*)
		sed -n '5,10p' "$0" | sed 's/^# \{0,1\}//' >&2
		exit 1
		;;
	esac
}

setup() {
	if ! is_installed "$TASKER_PACKAGE"; then
		printf 'Tasker is not installed. Opening its Play Store page on the phone. Install it, then run setup again.\n'
		adb shell am start -a android.intent.action.VIEW -d "market://details?id=${TASKER_PACKAGE}" >/dev/null
		exit 1
	fi

	if is_installed "$PLUGIN_PACKAGE"; then
		printf 'Plugin already installed: %s\n' "$(package_version "$PLUGIN_PACKAGE")"
	else
		install_plugin
	fi

	for permission in "${HEALTH_PERMISSIONS[@]}"; do
		adb shell pm grant "$PLUGIN_PACKAGE" "$permission" ||
			printf 'Could not grant %s over ADB. Grant it in the Tasker Health Connect app.\n' "$permission" >&2
	done

	adb shell cmd deviceidle whitelist "+${TASKER_PACKAGE}" >/dev/null
	printf 'Tasker added to the battery optimisation exemptions.\n'

	adb shell mkdir -p "$(dirname "$PHONE_BACKUP")"
	adb push "$script_dir/backup.xml" "$PHONE_BACKUP" >/dev/null
	printf 'Pushed backup.xml to %s\n\n' "$PHONE_BACKUP"
	printf 'Next: restore it in Tasker (README.md, "Restore the configuration"), then run: %s doctor\n' "$0"
}

install_plugin() {
	local download_dir
	download_dir="$(mktemp -d)"
	trap 'rm -rf "$download_dir"' EXIT

	local apk="$download_dir/TaskerHealthConnect-${PLUGIN_VERSION}.apk"
	curl -sSLo "$apk" "$PLUGIN_URL"
	if ! printf '%s  %s\n' "$PLUGIN_SHA256" "$apk" | sha256sum --check --status; then
		printf 'Checksum mismatch for %s. Not installing.\n' "$PLUGIN_URL" >&2
		exit 1
	fi
	adb install "$apk" >/dev/null
	printf 'Plugin installed: %s\n' "$(package_version "$PLUGIN_PACKAGE")"
}

doctor() {
	printf '== Device\n'
	printf 'Model: %s, Android %s\n' "$(adb shell getprop ro.product.model)" "$(adb shell getprop ro.build.version.release)"

	printf '\n== Apps\n'
	for package in "$TASKER_PACKAGE" "$PLUGIN_PACKAGE"; do
		if is_installed "$package"; then
			printf '%s %s\n' "$package" "$(package_version "$package")"
		else
			printf '%s NOT INSTALLED\n' "$package"
		fi
	done

	printf '\n== Health Connect permissions of the plugin\n'
	local granted
	granted="$(adb shell dumpsys package "$PLUGIN_PACKAGE" | grep -E 'granted=true' || true)"
	for permission in "${HEALTH_PERMISSIONS[@]}"; do
		if grep -q "${permission}: granted=true" <<<"$granted"; then
			printf 'OK       %s\n' "$permission"
		else
			printf 'MISSING  %s\n' "$permission"
		fi
	done

	printf '\n== Battery\n'
	if adb shell dumpsys deviceidle whitelist | grep -q "$TASKER_PACKAGE"; then
		printf 'OK       Tasker is exempt from battery optimisation\n'
	else
		printf 'MISSING  Tasker is battery optimised. Run setup, or exempt it in Settings > Apps > Tasker > Battery.\n'
	fi

	printf '\n== Last runs\n'
	show_runlog 12
}

show_runlog() {
	local lines="$1"
	adb shell "cat $PHONE_RUNLOG 2>/dev/null" | grep -E 'pasos|Display Unlocked|P Instant +ID[0-9]+ +23:50' | tail -n "$lines" ||
		printf 'No run log at %s. Turn it on in Tasker: More options > More > Run Log.\n' "$PHONE_RUNLOG"
}

show_inventory() {
	if ! adb shell "cat $PHONE_INVENTORY" 2>/dev/null; then
		printf 'No inventory yet. In Tasker, run the "Inventario pasos" task, then run this again.\n' >&2
		exit 1
	fi
	printf '\nThe file is appended to on every run. Delete it before the next run: adb shell rm %s\n' "$PHONE_INVENTORY"
}

require_command() {
	local command="$1" install_hint="$2"
	if ! command -v "$command" >/dev/null; then
		printf '%s not found. Install it: %s\n' "$command" "$install_hint" >&2
		exit 1
	fi
}

require_device() {
	if ! adb get-state >/dev/null 2>&1; then
		printf 'No phone connected over ADB. See README.md, "Connect the phone".\n' >&2
		exit 1
	fi
}

is_installed() {
	adb shell pm list packages "$1" | grep -qx "package:$1"
}

package_version() {
	adb shell dumpsys package "$1" | grep -m1 -oE 'versionName=[^ ]+' | cut -d= -f2
}

script_dir="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" && pwd)"

main "$@"
