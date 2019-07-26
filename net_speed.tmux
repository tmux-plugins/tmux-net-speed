#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/scripts/helpers.sh"

download_speed="#($CURRENT_DIR/scripts/download_speed.sh)"
net_speed="#($CURRENT_DIR/scripts/net_speed.sh)"
upload_speed="#($CURRENT_DIR/scripts/upload_speed.sh)"

download_interpolation="\#{download_speed}"
net_interpolation="\#{net_speed}"
upload_interpolation="\#{upload_speed}"

do_interpolation() {
	local input=$1
    local result=""

	result=${input/$download_interpolation/$download_speed}
	result=${result/$net_interpolation/$net_speed}
	result=${result/$upload_interpolation/$upload_speed}

	echo $result
}

update_tmux_option() {
	local option=$1
	local option_value=$(get_tmux_option "$option")
	local new_option_value=$(do_interpolation "$option_value")
	set_tmux_option "$option" "$new_option_value"
}

main() {
	update_tmux_option "status-right"
	update_tmux_option "status-left"
}
main
