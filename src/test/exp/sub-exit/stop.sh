#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

#
#
#

set -o posix # use standard mode
set -o nounset # fail on unset variables
set -o errexit  # fail on non-zero function return
set -o errtrace # apply ERR trap throughout call stack
set -o functrace # apply DEBUG and RETURN trap throughout the stack

trap_exit() {
    echo "$FUNCNAME $BASH_SUBSHELL ${BASH_LINENO[1]}"
}

trap trap_exit EXIT
trap trap_exit TERM

main() {
    echo "$FUNCNAME $BASH_SUBSHELL"
    exit
}

main

echo "no run"
