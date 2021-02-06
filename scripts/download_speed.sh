#!/bin/bash -

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

sum_download_speed()
{
    # Output uses first column
    sum_speed 1
}

main()
{
    # TODO make configurable
    if ! is_update_needed $DOWNLOAD_TIME_FILE; then
        local vel=$(read_file $DOWNLOAD_CACHE_FILE)
    else
        local file=$DOWNLOAD_FILE
        local old_val=$(read_file $file)
        local new_val=$(sum_download_speed)

        write_file $file $new_val
        local vel=$(get_velocity $new_val $old_val)

        write_file $DOWNLOAD_TIME_FILE $(date +%s)
        write_file $DOWNLOAD_CACHE_FILE "$vel"
    fi

    ## Format output
    local format=$(get_tmux_option @download_speed_format "%s")
    printf "$format" "$vel"
}
main

