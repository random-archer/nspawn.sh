#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

set -o posix # use standard mode
set -o nounset # fail on unset variables
set -o errexit  # fail on non-zero function return
set -o errtrace # apply ERR trap throughout call stack 
set -o functrace # apply DEBUG and RETURN trap throughout the stack

# project layout
readonly proj_dir=$(cd "${BASH_SOURCE%/*}/../" && pwd)
readonly main_dir="$proj_dir/main"
readonly test_dir="$proj_dir/test"
readonly test_lib_dir="$test_dir/lib"
readonly test_res_dir="$test_dir/res"

# provided by head.sh
declare -rx ns_build_name="nstests.sh"
declare -rx ns_build_stamp="2001-01-01_01-01-01"

provide_source() {
    local IFS=$'\n'
    local exec="exec.sh"
    local path=; for path in "$main_dir"/*.sh "$test_lib_dir"/*.sh ; do
        [[ $path =~ $exec ]] && continue # skip launchers
        source "$path"
    done 
}

provide_source
