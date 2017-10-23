#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

#
# application executor
#

set -o posix # use standard mode
set -o nounset # fail on unset variables
set -o errexit  # fail on non-zero function return
set -o errtrace # apply ERR trap throughout call stack 
set -o functrace # apply DEBUG and RETURN trap throughout the stack

# load script source files
ns_exec_source() {
    local IFS=$'\n'
    local base="${BASH_SOURCE%/*}" # this dir only
    local path=; for path in "$base"/*.sh ; do
        source "$path"
    done 
}

# protect function name space
ns_exec_func_lock() {
    local IFS=$'\n'
    local func= line=; for line in $(declare -F) ; do
        [[ $line =~ "declare -f ns_" ]] || continue
        func=${line##declare -f }
        declare -f -r "$func" # make read only
    done
}

# load source
ns_exec_source

# protect functions
ns_exec_func_lock

# start application
ns_init_all
ns_init_lock    
ns_main "$@"
