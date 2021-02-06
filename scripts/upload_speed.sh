#!/bin/bash -

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

sum_upload_speed()
{
    # Output uses ninth column
    sum_speed 9
}

main()
{
    # TODO make configurable
    #local upload_file=$(get_tmux_option $UPLOAD_FILE)
    if ! is_update_needed $UPLOAD_TIME_FILE; then
        local vel=$(read_file $UPLOAD_CACHE_FILE)
    else
        local file=$UPLOAD_FILE
        local old_val=$(read_file $file)
        local new_val=$(sum_upload_speed)

        write_file $file $new_val
        local vel=$(get_velocity $new_val $old_val)

        write_file $UPLOAD_TIME_FILE $(date +%s)
        write_file $UPLOAD_CACHE_FILE "$vel"
    fi

    ## Format output
    local format=$(get_tmux_option @upload_speed_format "%s")
    printf "$format" "$vel"
}
main

