#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# method to check if variable is declared 
# 

set -o nounset # fail on unset variables
set -o errexit  # fail on non-zero function return
set -o errtrace # apply ERR trap throughout call stack
set -o functrace # apply DEBUG and RETURN trap throughout the stack

check() {
    local "$@" # name
    
    # no good for array maps
    #[[ -v map ]] && echo yes || echo no
    
    # no good for array maps
    #[[ ${#map} ]] && echo yes || echo no
    
    # works for both scalar and array 
    &>/dev/null declare -p "$name" && echo yes || echo no
}

echo "# scalar"

check name=var
declare var
check name=var
declare var=1
check name=var

echo "# array"

check name=map
declare -A map=()
check name=map
declare -A map=([one]=1)
check name=map

### definition
    has_declare() {
        local "$@" # name
        &>/dev/null declare -p "$name"
    }

### invocation
    if has_declare name="vars_name" ; then
       echo "variable present: vars_name=$vars_name"
    fi
