#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

#
# detect sub shell return error 
# 

set -o posix # use standard mode
set -o nounset # fail on unset variables
set -o errexit  # fail on non-zero function return
set -o errtrace # apply ERR trap throughout call stack
set -o functrace # apply DEBUG and RETURN trap throughout the stack

on_error() {
    echo "$FUNCNAME $BASH_SUBSHELL"
    send_subshell
    exit 1
}

on_subshell() {
    echo "$FUNCNAME $BASH_SUBSHELL"
#    [[ $BASH_SUBSHELL == 0 ]] && exit 1 || 
    send_subshell
}

send_subshell() { 
    echo "$FUNCNAME $BASH_SUBSHELL"
    [[ $BASH_SUBSHELL == 0 ]] || kill -s USR1 $$
}

trap on_error ERR
trap on_subshell USR1 

func() {
    echo "$FUNCNAME $BASH_SUBSHELL"
    false # this is error 
}

# trigger trap ERR in sub shell
echo "$(func)"

# 
echo "### no error in main shell"
