#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

func() {
    
    echo "$BASH_SUBSHELL -----------"
    
#    set +o
#    printf %s\\n "$-"
    set +o | grep '\-o'
    
    echo "$BASH_SUBSHELL -----------"
    
set -o nounset # fail on unset variables
set -o errexit  # fail on non-zero function return
set -o errtrace # apply ERR trap throughout call stack
set -o functrace # apply DEBUG and RETURN trap throughout the stack
    
    echo "$BASH_SUBSHELL -----------"
    
#    set +o
#    printf %s\\n "$-"
    set +o | grep '\-o'
    
    echo "$BASH_SUBSHELL -----------"

}

func

echo "$(func)"
