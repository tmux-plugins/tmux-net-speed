#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

main()
{
    local download=$("$CURRENT_DIR/download_speed.sh")
    local upload=$("$CURRENT_DIR/upload_speed.sh")

    ## Format output
    local format=$(get_tmux_option @net_speed_format "D:%10s U:%10s")
    printf "$format" "$download" "$upload"
}
main
