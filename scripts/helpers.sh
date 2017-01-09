#!/bin/bash -

##
# Variables
##
DOWNLOAD_FILE="/tmp/tmux_net_speed.download"
UPLOAD_FILE="/tmp/tmux_net_speed.upload"

network_interfaces=()

wired_interface=""
wlan_interface=""

default_wired_network_adapter="eth0"
default_wlan_network_adapter="wlan0"

get_network_adapter_settings() {
	wired_interface=$(get_tmux_option "@net_wired_adapter" "$(default_wired_network_adapter)")
	wlan_interface=$(get_tmux_option "@net_wlan_adapter" "$(default_wlan_network_adapter)")
}

get_tmux_option() {
	local option="$1"
	local default_value="$2"
	local option_value="$(tmux show-option -gqv "$option")"
	if [[ -z "$option_value" ]]; then
		echo "$default_value"
	else
		echo "$option_value"
	fi
}

set_tmux_option() {
	local option=$1
	local value=$2
	tmux set-option -gq "$option" "$value"
}

get_velocity()
{
    local new_value=$1
    local old_value=$2

    # Consts
    local THOUSAND=1000
    local MILLION=100000

    local vel=$(( new_value - old_value ))
    local velKB=$(( vel / THOUSAND ))
    local velMB=$(( vel / MILLION ))

    if [[ $velMB != 0 ]] ; then
        echo -n "$velMB MB/s"
    elif [[ $velKB != 0 ]] ; then
        echo -n "$velKB KB/s";
    else
        echo -n "$vel B/s";
    fi
}

# Reads from value from file. If file does not exist,
# is empty, or not readable, starts back at 0
read_file()
{
   local path="$1"
   local val=0

   if [[ ! -f "$path" ]] ; then
       echo $val
       return
   elif [[ ! -r "$path" ]]; then
       echo $val
       return
   fi

   # Ok, file exists and is readdable. Check contents
   tmp=$(< "$path")
   if [[ "x${tmp}" == "x" ]] ; then
       echo $val
       return
   fi

   # else all good, echo value
   echo $tmp
}

# Update values in file
write_file()
{
   local path="$1"
   local val="$2"

   # TODO Add error checking
   echo "$val" > "$path"
}

sum_speed()
{
    local column=$1

    local interfaces=(
        $wired_interface
        $wlan_interface
    )

    local line=""
    local val=0
    for intf in ${interfaces[@]} ; do
        line=$(cat /proc/net/dev | grep "$intf" | cut -d':' -f 2)
        let val+=$(echo -n $line | cut -d' ' -f $column)
    done

    echo $val
}

is_osx() {
	[ $(uname) == "Darwin" ]
}

is_cygwin() {
	command -v WMIC > /dev/null
}

command_exists() {
	local command="$1"
	type "$command" >/dev/null 2>&1
}


