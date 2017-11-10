#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# error propagation from sub shell to parent:
# * YES, in plain invocation () 
# * NOT, in command substitution $()
#

set -o nounset # fail on unset variables
set -o errexit  # fail on non-zero function return
set -o errtrace # apply ERR trap throughout call stack
set -o functrace # apply DEBUG and RETURN trap throughout the stack

error() {
    echo "$FUNCNAME $BASH_SUBSHELL"
}

trap error ERR

func() {
    echo "$FUNCNAME $BASH_SUBSHELL"
    false # this is error
}

#func

# YES, trap in sub, then main 
#(func)
#(func)
#(func)

# NOT, in command substitution $() injection
#echo "$(func)"
#echo "$(func)"
#echo "$(func)"

# YES, in command substitution $() assignment
#var=$(func)
#var=$(func)
#var=$(func)

# YES, in direct evaluation
eval "$(func)"
eval "$(func)"
eval "$(func)"
