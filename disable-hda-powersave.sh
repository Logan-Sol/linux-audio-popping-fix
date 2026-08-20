#!/usr/bin/env bash

set -euo pipefail

CONFIG_FILE="/etc/modprobe.d/hda-no-powersave.conf"
POWER_SAVE="/sys/module/snd_hda_intel/parameters/power_save"
POWER_SAVE_CONTROLLER="/sys/module/snd_hda_intel/parameters/power_save_controller"

usage() {
	cat <<EOF
	Usage: $0 [apply|status|revert]
	
	Commands:
	apply    Disable Intel HDA power saving and make it persistent
	status   Show the current HDA power-saving settings
	revert   Remove the persistent configuration
	
	Examples:
	sudo $0 apply
	$0 status
	sudo $0 revert
	EOF
}

require_root() {
	if [[ $EUID -ne 0 ]]; then
		echo "Error: this command requires root privileges."
		echo "Run it with sudo."
		exit 1
		fi
}

status() {
	echo "Intel HDA power-saving status:"
	echo
	
	if [[ -f "$POWER_SAVE" ]]; then
		echo "power_save:              $(cat "$POWER_SAVE")"
		else
			echo "power_save:              unavailable"
			fi
			
			if [[ -f "$POWER_SAVE_CONTROLLER" ]]; then
				echo "power_save_controller:   $(cat "$POWER_SAVE_CONTROLLER")"
				else
					echo "power_save_controller:   unavailable"
					fi
					
					echo
					
					if [[ -f "$CONFIG_FILE" ]]; then
						echo "Persistent configuration:"
						cat "$CONFIG_FILE"
						else
							echo "Persistent configuration: not installed"
							fi
}

apply() {
	require_root
	
	echo "Disabling Intel HDA power saving..."
	
	if [[ -f "$POWER_SAVE" ]]; then
		echo 0 > "$POWER_SAVE"
		else
			echo "Warning: $POWER_SAVE not found."
			fi
			
			if [[ -f "$POWER_SAVE_CONTROLLER" ]]; then
				echo N > "$POWER_SAVE_CONTROLLER"
				else
					echo "Warning: $POWER_SAVE_CONTROLLER not found."
					fi
					
					echo "options snd_hda_intel power_save=0 power_save_controller=N" \
					> "$CONFIG_FILE"
					
					echo
					echo "Intel HDA power saving disabled."
					echo "Persistent configuration written to:"
					echo "  $CONFIG_FILE"
					echo
					echo "A reboot may be required for the persistent configuration"
					echo "to take effect after the next boot."
}

revert() {
	require_root
	
	if [[ -f "$CONFIG_FILE" ]]; then
		rm "$CONFIG_FILE"
		echo "Removed $CONFIG_FILE"
		else
			echo "Persistent configuration is not installed."
			fi
			
			echo
			echo "The persistent HDA power-saving configuration has been removed."
			echo "Reboot to restore the normal boot-time configuration."
}

case "${1:-}" in
	apply)
	apply
	;;
	status)
	status
	;;
	revert)
	revert
	;;
	*)
	usage
	exit 1
	;;
	esac
	
