#!/bin/bash -

##
# Varialbes
##
DOWNLOAD_FILE="/tmp/tmux_net_speed.download"
UPLOAD_FILE="/tmp/tmux_net_speed.upload"

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
        if [[ -n is_osx ]]
        then
            interfaces=$(netstat -i | tail +2 | sed -E 's/ +/ /g' | cut -d ' ' -f 1 | sort -u | grep "en")
        else
            for interface in /sys/class/net/*; do
                interfaces+=$(echo $(basename $interface) " ");
            done
        fi
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
        line=$(get_speed $intf)
        speed="$(echo -n $line | cut -d' ' -f $column)"
        let val+=${speed:=0}
    done

    echo $val
}

get_speed()
{
    local interface=$1

    if [[ -n is_osx ]]
    then
        line="$(netstat -b -i -I "$interface" | tail +2 | sed -E 's/ +/ /g' | cut -d ' ' -f 1,7,10 | uniq )" 
        down=$(echo -n $line | cut -d ' ' -f 2)
        up=$(echo -n $line | cut -d ' ' -f 3)
        echo "$down 0 0 0 0 0 0 0 $up"
    else
        echo $(cat /proc/net/dev | grep "$interface" | cut -d':' -f 2)
    fi
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
