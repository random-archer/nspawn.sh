#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh
#!

#
# install/launcher
#
set -o nounset # fail on unset variables
set -o errexit  # fail on any non-zero return
set -o pipefail # fail on any internal pipe error
set -o errtrace # apply ERR trap throughout call stack
set -o functrace # apply DEBUG and RETURN trap throughout the stack 

# discover install folder
ns_inst_dir() {
    local temp_dir="/tmp" # default temporary folder
    local user_dir="/run/user/$UID" # user runtime folder
    if [[ -d $user_dir ]] ; then echo "$user_dir"
    elif [[ -d $temp_dir ]] ; then echo  "$temp_dir"
    else 1>&2 echo "unknown system" ; return 1 ; fi
}

# report install errors
ns_inst_trap_error() {
    local nest=${BASH_SUBSHELL}
    local func=${FUNCNAME[1]}
    local line=${BASH_LINENO[1]}
    local file=${BASH_SOURCE[0]}
    1>&2 echo "#ERR nest='$nest' func='$func' line='$line' file='$file'"
}

# provision program resources
ns_inst_path() {
    local inst_dir=; inst_dir=$(ns_inst_dir)
    local exec_dir="$inst_dir/$ns_build_name/$ns_build_stamp" # program folder
    local exec_pack="$exec_dir.tar.gz" # extracted archive
    if [[ ! -d $exec_dir ]] ; then # install only once
        1>&2 mkdir -p "$exec_dir" # ensure install folder
        sed '0,/^ARCHIVE$/d' "$BASH_SOURCE" > "$exec_pack" # extract archive
        1>&2 tar -x -C "$exec_dir" -f "$exec_pack" # extract program
        1>&2 chmod -R go-rwx "$exec_dir"/ # limit access
        1>&2 rm -f "$exec_pack" # cleanup archive
    fi
    local exec_path="$exec_dir/exec.sh" # program entry point
    echo "$exec_path"
}

# report install errors
trap ns_inst_trap_error ERR

# define globals
declare -r ns_build_name="{build_name}"
declare -r ns_build_stamp="{build_stamp}"

# invoke executor
ns_inst_exec=$(ns_inst_path)
declare -r ns_inst_exec
source "$ns_inst_exec"

# terminate program
exit $?

# archive separator
ARCHIVE
