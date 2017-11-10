#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# no ERR trap on "unbound variable", only EXIT trap
#

set -o nounset # fail on unset variables
set -o errexit  # fail on non-zero function return
set -o errtrace # apply ERR trap throughout call stack
set -o functrace # apply DEBUG and RETURN trap throughout the stack

on_exit() {
    echo "$FUNCNAME $? ${FUNCNAME[1]}"
}

on_error() {
    echo "$FUNCNAME $? ${FUNCNAME[1]}"
}

main() {
    echo "$FUNCNAME $? ${FUNCNAME[1]}"
    echo $XXX
}

trap on_exit EXIT
trap on_error ERR

main
