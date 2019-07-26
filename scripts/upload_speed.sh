#!/usr/bin/env bash

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
    local file=$UPLOAD_FILE
    local old_val=$(read_file $file)
    local new_val=$(sum_upload_speed)

    write_file $file $new_val
    local vel=$(get_velocity $new_val $old_val)

    ## Format output
    local format=$(get_tmux_option @upload_speed_format "%s")
    printf "$format" "$vel"
}
main

