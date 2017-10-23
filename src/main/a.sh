#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

#
# common functions
#

# ISO date/time stamp
ns_a_date_time() { 
    date +"%Y-%m-%d_%H-%M-%S" 
} 

# generate random id 
ns_a_guid() { 
    cat "/proc/sys/kernel/random/uuid"
}

# generate random id 
ns_a_guid_char() {
    local guid=$(ns_a_guid)
    echo "${guid//-/}" 
}

# invoke as root when needed
ns_a_sudo() { 
    ns_log_note "$@" 
    ns_a_has_root && "$@" || sudo -E "$@"
}

# detect root user
ns_a_has_root() { 
    [[ $EUID == 0 ]] 
}

# read in-line here-doc
ns_a_define() {  
    local IFS=$'\n' ; read -r -d '' ${1} || return 0
}

# self name
ns_a_prog_name() {
    echo "$ns_build_name"
}

# self version
ns_a_prog_version() {
    echo "$ns_build_name/$ns_build_stamp"
}

# check array-by-name is non-empty
ns_a_has_array() {
    local "$@" ; [[ "$(set +o nounset; echo ${!name})" ]]
} 

# map linear array
ns_a_list_apply() {
    local "$@"
    ns_a_has_array name="$list" || return 0
    local array="$list[@]" # by name
    local entry= ; for entry in "${!array}" ; do 
        $apply entry="$entry" # apply map
    done
}

# map associative array
ns_apply_map() { 
    false # TODO
    local "$@" ; local key= value= array="$map[@]" 
    for key in "${!array}" ; do $apply key="$key" value="${map[$key]}" ; done
}

# save input to a file
ns_a_save() { 
    local "$@"
    ns_a_mkpar
    ns_a_sudo dd status=none of="$file"
}

# make folder tree
ns_a_mkdir() { 
    local "$@" # dir
    ns_a_sudo mkdir -p "$dir"
}

# kill folder tree
ns_a_rmdir() { 
    local "$@" # dir
    ns_a_sudo rm -r -f "$dir"
}

# make parent folders of a path
ns_a_mkpar() { 
    local "$@" # file
    ns_a_mkdir dir="${file%/*}"
}

# verify variable injection
ns_a_args_assert() { 
    local "$@" && return 0
    ns_log_fail "invalid 'key=value' args line: '$@'" 
}

# verify entry is present in array
ns_a_array_contains() { 
    local "$@"
    local -n list="$array" # de-reference
    local item= ; for item in "${list[@]-}" ; do 
        [[ $item == $entry ]] && return 0 # present
    done
    return 1 # missing
}


# remove head/tail whitespace characters
ns_a_trim() { 
    local "$@" # line
    line="${line#"${line%%[![:space:]]*}"}" # trim head
    line="${line%"${line##*[![:space:]]}"}" # trim tail
    echo -n "$line"
}

# report folder disk size
ns_a_dir_size() {
    local "$@" # path
    echo $(ns_a_sudo du -s -h "$path")
}


# verify if two paths have same time stamp
ns_a_has_same_stamp() {
    local "$@" # path1 path2
    [[ ! $path1 -nt $path2 ]] && [[ ! $path1 -ot $path2 ]]
}

# string digest
ns_a_text_hash() {
    local "$@" # text
    local -a hash=($(echo -n "$text" | md5sum)) # note "-n"
    echo "${hash[0]}"
}

# verify if variable is declared
ns_a_has_declare() {
    &>/dev/null declare -p "$1"
}

# read scalar/array declared value
ns_a_read_declare() {
    local entry=$(declare -p "$1")
    echo "${entry#*=}" # cut [declare -? name=]
}

# dir-name part of the path 
ns_a_path_dir() {
    local "$@" # path
    cd "${path%/*}" && pwd
}

# base-name part of the path 
ns_a_path_file() {
    local "$@" # path
    echo "${path##*/}"
}

# function call stack 
ns_a_stack_depth() {
    echo ${#FUNCNAME[@]}    
}

# repeat character
ns_a_char_reps() {
    local "$@" # char reps
    local item=; 
    for (( item=1 ; item <= reps ; item++ )) ; do
        printf "$char"
    done
}
