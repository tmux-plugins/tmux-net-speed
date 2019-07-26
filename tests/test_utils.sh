#!/usr/bin/env bash
###############################################################################
# Author: Travis Goldie
# Purpose: Util funcs for unit tests
###############################################################################
##
# Description:
# Asserts if `$1` equals `$2`
##
assertEqual()
{
    local input=$1
    local expected=$2
    local msg=$3

    if [[ "$4" == "-v" ]] ; then
        echo $@
    fi

    if [[ -z msg ]] ; then
        msg="Failed test"
    fi

    test "$1" == "$2"
    err=$?

    if [[ $err == 0 ]] ; then
        echo "[PASSED]: ${msg}"
        echo
        return $err
    fi

    if [[ $err != 0 ]] ; then
        echo "[FAILED]: ${msg}"
        echo
        return $err
    fi
}

##
# Description:
# Asserts if `$1` not equals `$2`
##
assertNotEqual()
{
    local input=$1
    local expected=$2
    local msg=$3

    if [[ -z msg ]] ; then
        msg="Failed test"
    fi

    test "$1" != "$2"
    err=$?

    if [[ $err == 0 ]] ; then
        echo "[PASSED]: ${msg}"
        echo
        return $err
    fi

    if [[ $err != 0 ]] ; then
        echo "[FAILED]: ${msg}"
        echo
        return $err
    fi
}

##
# @description
# Checks to see if error code is non-zero. If so, echo message and exit
# with the given error code.
#
# ``` bash
# $ someCmd blah blah2
# $ err=$?
# $ die $err "If err is non-zero this script will exit"
# ```
##
die()
{
    local err=$1
    local msg=$2
    local name=$( basename $0 )

    if [[ $err != 0 ]] ; then
        echo "[ERROR]:${name}:code $err:${msg}"
        exit $err
    fi
}
