#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# detect sub shell return error 
# 

set -o nounset # fail on unset variables
set -o errexit  # fail on non-zero function return
set -o errtrace # apply ERR trap throughout call stack
set -o functrace # apply DEBUG and RETURN trap throughout the stack

error_handler() {
    echo "$FUNCNAME $BASH_SUBSHELL RV=$?"
}

return_handler() {
    echo "$FUNCNAME $BASH_SUBSHELL RV=$?"
}

trap error_handler ERR
trap return_handler RETURN

func() {
    echo "$FUNCNAME $BASH_SUBSHELL"
    false # this is error 
}

# trigger trap ERR in sub shell
# trigger trap RETURN in sub shell
# trigger NOTHING in main shell

echo "$(func)"
echo "no error in main shell"
