#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# application executor
#

# import script source files
ns_exec_source() {
    local IFS=$'\n'
    local base="${BASH_SOURCE%/*}" # this dir only
    local path=; for path in "$base"/*.sh ; do
        source "$path"
    done 
}

# protect function name space
ns_exec_protect() {
    local decl="declare -f " # report prefix
    local rx_cmd="${decl}[A-Z!]+" # build commands
    local rx_fun="${decl}ns_.+" # internal functions
    local rx_any="($rx_cmd|$rx_fun)" # match
    local IFS=$'\n'; local line=; for line in $(declare -F) ; do
        [[ $line =~ $rx_any ]] || continue # no match
        local func=${line##${decl}} # extract name
        declare -f -r "$func" # make read only
    done
}

# import source
ns_exec_source

# protect functions
ns_exec_protect

# start application
ns_init_all
ns_init_lock
ns_main "$@"
