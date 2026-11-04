#!/bin/bash
#
# Lets a touch on a FIDO2 key (YubiKey) replace the password in sudo and in polkit pop-ups.
# The password stays as a fallback. Login and the lock screen keep using the password,
# because a login without it leaves the GNOME keyring locked. See "YubiKey" in README.md.
#
# Usage:
#   setup-yubikey-pam.sh setup    Install and configure everything. Safe to re-run. Asks for sudo.
#   setup-yubikey-pam.sh enroll   Replace this user's credential, for example after a hostname change. Asks for sudo.
#   setup-yubikey-pam.sh doctor   Show the state of every part. Changes nothing and needs no sudo.
#
# Each machine generates its own credential, so this repository holds no key data.
# Do not add pam_u2f's "debug" option to polkit-1: it put polkit's helper in a restart loop.
#
set -euo pipefail

PACKAGES=(libpam-u2f pamu2fcfg)
YUBICO_USB_VENDOR="1050"

PAM_DIR="/etc/pam.d"
PAM_SERVICES=(sudo sudo-i polkit-1)
AUTHFILE="/etc/Yubico/u2f_keys"
PAM_RULE="auth sufficient pam_u2f.so authfile=$AUTHFILE cue"
PAM_RULE_PATTERN='^auth[[:space:]]+sufficient[[:space:]]+pam_u2f\.so.*$'
PAM_INCLUDE="@include common-auth"
# These must never hold the rule. See the header for why login stays on the password.
PAM_SERVICES_WITHOUT_RULE=(common-auth gdm-password)

# Polkit 127 and later run the helper in a sandbox that hides the key and /dev/urandom from pam_u2f.
POLKIT_HELPER_UNIT="polkit-agent-helper@.service"
POLKIT_HELPER_INSTANCE="polkit-agent-helper@check.service"
DROPIN_DIR="/etc/systemd/system/$POLKIT_HELPER_UNIT.d"
DROPIN_FILE="$DROPIN_DIR/u2f.conf"

BACKUP_ROOT="/var/backups/yubikey-pam"

main() {
	case "${1:-}" in
	setup) setup ;;
	enroll) enroll ;;
	doctor) doctor ;;
	*)
		sed -n '/^# Usage:/,/^#   .*doctor/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//' >&2
		exit 2
		;;
	esac
}

setup() {
	require_not_root
	local service
	for service in "${PAM_SERVICES[@]}"; do
		check_pam_file "$service"
	done
	install_packages
	require_key
	sudo -v
	backup_config

	if has_credential; then
		echo "Keeping the credential for $USER in $AUTHFILE."
	else
		write_credential
	fi

	for service in "${PAM_SERVICES[@]}"; do
		apply_pam_rule "$service"
	done
	apply_polkit_sandbox_exception

	echo
	doctor
}

enroll() {
	require_not_root
	command -v pamu2fcfg >/dev/null || die "pamu2fcfg is missing. Run: setup-yubikey-pam.sh setup"
	require_key
	sudo -v
	backup_config
	write_credential
	echo "Run: sudo -k; sudo -v"
}

require_not_root() {
	[[ "$(id -u)" -ne 0 ]] || die "Run this as your own user. It asks for sudo when it needs it."
}

check_pam_file() {
	local file="$PAM_DIR/$1"
	[[ -f "$file" ]] || die "$file does not exist."
	if grep -q 'pam_u2f' "$file"; then
		grep -Eq "$PAM_RULE_PATTERN" "$file" ||
			die "$file uses pam_u2f in a way this script does not expect. Fix it by hand."
	else
		grep -qxF "$PAM_INCLUDE" "$file" || die "$file has no '$PAM_INCLUDE' line."
	fi
}

install_packages() {
	local package missing=()
	for package in "${PACKAGES[@]}"; do
		dpkg -s "$package" >/dev/null 2>&1 || missing+=("$package")
	done
	if [[ "${#missing[@]}" -gt 0 ]]; then
		sudo apt-get install -y "${missing[@]}"
	fi
}

key_is_plugged_in() {
	grep -qs "^$YUBICO_USB_VENDOR\$" /sys/bus/usb/devices/*/idVendor
}

require_key() {
	key_is_plugged_in || die "No YubiKey found. Plug it in and run this again."
}

backup_config() {
	local backup_dir
	backup_dir="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"
	sudo install -d -m 700 -o root -g root "$backup_dir"

	local service
	for service in "${PAM_SERVICES[@]}"; do
		sudo cp -a "$PAM_DIR/$service" "$backup_dir/"
	done
	if [[ -f "$AUTHFILE" ]]; then
		sudo cp -a "$AUTHFILE" "$backup_dir/"
	fi
	if [[ -f "$DROPIN_FILE" ]]; then
		sudo cp -a "$DROPIN_FILE" "$backup_dir/"
	fi
	echo "Backup: $backup_dir"
}

has_credential() {
	grep -qs "^$USER:" "$AUTHFILE"
}

# Keeps the lines of other users. The key must be touched here.
write_credential() {
	echo "Touch the key when it blinks."
	local credential new_file
	credential="$(pamu2fcfg -u "$USER")"
	new_file="$(mktemp)"

	if [[ -f "$AUTHFILE" ]]; then
		# sed adds a final newline if it is missing, which pamu2fcfg output has.
		# shellcheck disable=SC1003
		grep -v "^$USER:" "$AUTHFILE" | sed -e '$a\' >"$new_file" || true
	fi
	printf '%s\n' "$credential" >>"$new_file"

	sudo install -d -m 755 -o root -g root "$(dirname "$AUTHFILE")"
	sudo install -m 644 -o root -g root "$new_file" "$AUTHFILE"
	rm -f "$new_file"
}

# Replaces the rule if it exists. Otherwise it goes directly above common-auth, which holds the password check.
apply_pam_rule() {
	local file="$PAM_DIR/$1"
	if grep -Eq "$PAM_RULE_PATTERN" "$file"; then
		sudo sed -E -i "s|$PAM_RULE_PATTERN|$PAM_RULE|" "$file"
	else
		sudo sed -i "s|^$PAM_INCLUDE\$|$PAM_RULE\n&|" "$file"
	fi
}

polkit_helper_is_sandboxed() {
	systemctl cat "$POLKIT_HELPER_UNIT" >/dev/null 2>&1
}

apply_polkit_sandbox_exception() {
	if ! polkit_helper_is_sandboxed; then
		echo "Polkit has no sandboxed helper here, so it needs no exception."
		return
	fi
	sudo install -d -m 755 -o root -g root "$DROPIN_DIR"
	sudo tee "$DROPIN_FILE" >/dev/null <<'EOF'
[Service]
PrivateDevices=no
DeviceAllow=char-hidraw rw
DeviceAllow=/dev/urandom r
EOF
	sudo chmod 644 "$DROPIN_FILE"
	sudo systemctl daemon-reload
}

doctor() {
	local problems=0

	local package
	for package in "${PACKAGES[@]}"; do
		if dpkg -s "$package" >/dev/null 2>&1; then
			report_ok "package $package"
		else
			report_problem "package $package is not installed"
		fi
	done

	if key_is_plugged_in; then
		report_ok "YubiKey plugged in"
	else
		report_problem "no YubiKey plugged in"
	fi

	if [[ "$(stat -c '%a %U:%G' "$AUTHFILE" 2>/dev/null)" == "644 root:root" ]]; then
		report_ok "$AUTHFILE is root-owned, mode 644"
	else
		report_problem "$AUTHFILE is missing, or is not root-owned with mode 644"
	fi
	if has_credential; then
		report_ok "credential for $USER"
	else
		report_problem "no credential for $USER in $AUTHFILE"
	fi

	local service
	for service in "${PAM_SERVICES[@]}"; do
		if grep -qxF "$PAM_RULE" "$PAM_DIR/$service" 2>/dev/null; then
			report_ok "$PAM_DIR/$service has the rule"
		else
			report_problem "$PAM_DIR/$service does not have the rule"
		fi
	done
	for service in "${PAM_SERVICES_WITHOUT_RULE[@]}"; do
		if grep -qs 'pam_u2f' "$PAM_DIR/$service"; then
			report_problem "$PAM_DIR/$service uses pam_u2f, so login may skip the password"
		else
			report_ok "$PAM_DIR/$service keeps the password only"
		fi
	done

	if polkit_helper_is_sandboxed; then
		local device_allow
		device_allow="$(systemctl show "$POLKIT_HELPER_INSTANCE" -p DeviceAllow)"
		if [[ "$device_allow" == *char-hidraw* && "$device_allow" == */dev/urandom* ]]; then
			report_ok "polkit helper can reach the key"
		else
			report_problem "polkit helper cannot reach the key"
		fi
	fi

	if [[ -f "$HOME/.config/Yubico/u2f_keys" ]]; then
		report_problem "old $HOME/.config/Yubico/u2f_keys is unused. Delete it"
	fi

	echo
	if [[ "$problems" -gt 0 ]]; then
		echo "$problems problem(s) found."
		return 1
	fi
	echo "No problems found. Test with: sudo -k; sudo -v"
	echo "Then test a pop-up with: pkexec /usr/bin/true"
}

report_ok() {
	echo "OK       $1"
}

# Reads and changes the "problems" variable of doctor, through bash's dynamic scoping.
report_problem() {
	echo "PROBLEM  $1"
	problems=$((problems + 1))
}

die() {
	echo "Error: $1" >&2
	exit 1
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	main "$@"
fi
