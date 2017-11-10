#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# unit test executor
#

set -o nounset # fail on unset variables
set -o errexit  # fail on non-zero function return
set -o errtrace # apply ERR trap throughout call stack 
set -o functrace # apply DEBUG and RETURN trap throughout the stack

# unit test executor
exec_unit_test() {
    # debug prompt
    export PS4='-> ${BASH_SOURCE##*/}:${LINENO} '
    
    local count_invoked=0
    local count_failure=0
    local failure_list=()

    local IFS=$'\n'
    local base="${BASH_SOURCE%/*}"
    local unit=; for unit in "$base"/*Test.sh ; do 
        IFS=
        echo
        
        # test run
        echo "------- $unit -------"
        (( count_invoked++ )) || true
        $BASH "$unit" && continue
        
        # debug run
        echo "------- $unit -------"
        (( count_failure++ )) || true
        failure_list+=("$unit")
        $BASH -x "$unit" || true
         
    done

    # produce summary
    echo
    echo "----------------------------"
    echo "count_invoked=$count_invoked"
    echo "count_failure=$count_failure"
    echo "failure_list:"
    local entry=; for entry in "${failure_list[@]}" ; do
        echo "   $entry"
    done 
    
    # fail on error
    (( count_failure == 0 ))
}

# unit test executor
exec_unit_test
