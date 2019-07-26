#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS="$CURRENT_DIR/../../scripts"
source "$CURRENT_DIR/../test_utils.sh"

##
# Description:
# General setup before each test
##
setup()
{
    source "$SCRIPTS/helpers.sh"
}

##
# get_tmux_option
##
setup_get_tmux_option()
{
    setup

    ## Set generic property
    tmux set @get_tmux_option_name "get_tmux_option_val"
}

cleanup_get_tmux_option()
{
    # Unset value
    tmux set -u @get_tmux_option_name
}

test_get_tmux_option()
{
    ##
    # Should return set value
    ##
    setup_get_tmux_option

    result=$( get_tmux_option "@get_tmux_option_name")
    assertEqual "$result" "get_tmux_option_val" "should get tmux prop when given no default" -v

    cleanup_get_tmux_option

    ##
    # Should show set value
    ##
    setup_get_tmux_option

    result=$( get_tmux_option "@get_tmux_option_name_unset")
    assertEqual "$result" "" "should get empty string when tmux prop unset"

    cleanup_get_tmux_option

    ##
    # Should show set value
    ##
    setup_get_tmux_option

    result=$( get_tmux_option @get_tmux_option_name_unset my_default)
    assertEqual "$result" "my_default" "should get default if provided for unset prop"

    cleanup_get_tmux_option
}

##
# get_velocity
##
setup_get_velocity()
{
    setup
}

cleanup_get_velocity() { :; }

test_get_velocity()
{
    setup_get_velocity
    let input=200
    result=$(get_velocity $input 0)
    assertEqual "$result" "200 B/s" "should show B/s"
    cleanup_get_velocity

    setup_get_velocity
    let input=2*1024
    result=$(get_velocity $input 0)
    assertEqual "$result" "2 KB/s" "should show KB/s"
    cleanup_get_velocity

    setup_get_velocity
    let input=3*1048576
    result=$(get_velocity $input 0)
    assertEqual "$result" "3 MB/s" "should show MB/s"
    cleanup_get_velocity


    setup_get_velocity
    let subtract_from=100*1048576
    let subtract_with=50*1048576
    result=$(get_velocity $subtract_from subtract_with)
    assertEqual "$result" "50 MB/s" "should show MB/s if subraction done"
    cleanup_get_velocity
}

##
# get_interfaces
##
setup_get_interfaces()
{
    setup
}

cleanup_get_interfaces() { :; }

test_get_interfaces()
{
    setup_get_interfaces
    result=$(get_interfaces)
    assertEqual "$result" "eth0 lo wlan0" "should output space-delimited list of interfaces" -v
    cleanup_get_interfaces
}

suites()
{
    #test_get_tmux_option
    #test_get_velocity
    test_get_interfaces
}

# Run tests
suites

