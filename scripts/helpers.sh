#!/bin/bash -

##
# Varialbes
##
DOWNLOAD_FILE="/tmp/tmux_net_speed.download"
UPLOAD_FILE="/tmp/tmux_net_speed.upload"
DOWNLOAD_CACHE_FILE="/tmp/tmux_net_speed.download.cache"
UPLOAD_CACHE_FILE="/tmp/tmux_net_speed.upload.cache"
DOWNLOAD_TIME_FILE="/tmp/tmux_net_speed.download.time"
UPLOAD_TIME_FILE="/tmp/tmux_net_speed.upload.time"

get_tmux_option() {
    local option=$1
    local default_value=$2
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

is_update_needed()
{
    local update_file=$1

    local interval=$(get_tmux_option 'status-interval' 5)
    local update_time=$(read_file $update_file)
    local cur_time=$(date +%s)
    if [ $((update_time + interval)) -gt $cur_time ]; then
        return 1;
    fi;
    return 0;
}

get_velocity()
{
    local new_value=$1
    local old_value=$2

    # Consts
    local THOUSAND=1024
    local MILLION=1048576

    local interval=$(get_tmux_option 'status-interval' 5)
    local vel=$(( ( new_value - old_value ) / interval ))
    local vel_kb=$(( vel / THOUSAND ))
    local vel_mb=$(( vel / MILLION ))

    if [[ $vel_mb != 0 ]] ; then
        echo -n "$vel_mb MB/s"
    elif [[ $vel_kb != 0 ]] ; then
        echo -n "$vel_kb KB/s";
    else
        echo -n "$vel B/s";
    fi
}

# Reads from value from file. If file does not exist,
# is empty, or not readable, starts back at 0
read_file()
{
    local path="$1"
    local fallback_val=0

    # File exists and is readdable?
    if [[ ! -f "$path" ]] ; then
        echo $fallback_val
        return 1
    elif [[ ! -r "$path" ]]; then
        echo $fallback_val
        return 1
    fi


    # Does the file have content?
    tmp=$(< "$path")
    if [[ "x${tmp}" == "x" ]] ; then
        echo $fallback_val
        return 1
    fi

    # Now return known value
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

get_interfaces()
{
    local interfaces=$(get_tmux_option @net_speed_interfaces "")

    if [[ -z "$interfaces" ]] ; then
        for interface in /sys/class/net/*; do
            interfaces+=$(echo $(basename $interface) " ");
        done
    fi

    # Do not quote the variable. This way will handle trailing whitespace
    echo -n $interfaces
}

sum_speed()
{
    local column=$1

    declare -a interfaces=$(get_interfaces)

    local line=""
    local val=0
    for intf in ${interfaces[@]} ; do
        line=$(cat /proc/net/dev | grep "$intf" | cut -d':' -f 2)
        speed="$(echo -n $line | cut -d' ' -f $column)"
        let val+=${speed:=0}
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
