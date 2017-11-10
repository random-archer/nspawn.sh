#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

# name space leak
exec_check_space() {
    if declare -p | grep 'ns_' ; then
        echo "constants leak" 
        return 1 
    fi
    if declare -F | grep 'ns_' ; then 
        echo "functions leak" 
        return 2 
    fi
}
