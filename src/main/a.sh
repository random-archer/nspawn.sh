#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
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

# invoke as root on demand
ns_a_sudo() { 
    ns_log_note "$@" 
    ns_a_has_root && "$@" || sudo -E "$@"
}

# generate sudo on demand
ns_a_suno() {
    ns_a_has_root && echo "" || echo "sudo -E"
}
    
# detect root user
ns_a_has_root() { 
    [[ $EUID == 0 ]] 
}

# read in-line here-doc
ns_a_define() { 
    # read multiple lines
    # use new-line separators
    # use timeout to detect missing << EOF
    local IFS=$'\n' ; read -r -t 0.1 -d '' $1 || return 0
}

# self name
ns_a_prog_name() {
    echo "$ns_build_name"
}

# self signature
ns_a_prog_sign() {
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

# make parent folders of a path
ns_a_mkpar() { 
    local "$@" # file
    ns_a_sudo mkdir -p "${file%/*}"
}

# verify key=val injection format
ns_a_args_assert() { 
    # ns_log_note
    local entry=; for entry in "$@" ; do
        [[ $entry == *"="* ]] && continue
        ns_log_fail "invalid 'key=value' args line: '$@'" 
    done
}

# verify entry is present in array
ns_a_array_contains() { 
    local "$@" # @array entry
    local -n list="$array" # de-reference
    local item=; for item in "${list[@]-}" ; do 
        [[ $item == $entry ]] && return 0 # present
    done
    return 1 # missing
}

# join array into string with separator 
ns_a_array_join() {
    local "$@" # @array separ
    local -n list="$array" # de-reference
    local line="${list[0]-}"
    local item=; for item in "${list[@]:1}" ; do 
        line+="$separ$item"
    done
    echo "$line"
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

# verify if named variable is declared
ns_a_has_declare() {
    &>/dev/null declare -p "$1" # name
}

# read raw named declared variable value
ns_a_read_declare() {
    local entry=$(declare -p "$1") # name
    entry=${entry#*=} # cut [declare -? name=]
    entry=$(ns_parse_rem_quote_any "$entry")
    echo "$entry"
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

# list tree to path
ns_a_path_explode() {
    local "$@" # path
    # special case
    [[ $path == "/" ]] && echo "/" && return 0
    # split into array  
    local IFS=$'/' ; local -a list=( $path ) ; unset IFS
    # re-build partial paths
    local index=0 length=${#list[@]}
    while (( index <= length )) ; do
        # select subset
        local -a scan=( "${list[@]:0:$index}" )
        # merge path back
        local line=$(IFS=$'/' ; echo "${scan[*]}")
        # non empty entries
        [[ $line ]] && echo "$line"
        # iterate 
        (( index++ )) || true
    done
}

# create/delete a resource
ns_a_resource() {
    eval "local $@" ; ns_log_req mode file
    case "$mode" in
        create)
            ns_log_req text
            echo "$text" | ns_a_save
            ;;
        delete)
            ns_a_sudo rm -f "$file" 
            ;;
        ignore) 
            ;;
        *) ns_log_fail "wrong mode '$mode'" ;;
    esac 
    #
}

# find system temp dir
ns_a_temp_dir() {
    local temp=$(mktemp -u -t temp.XXXXXXXXXX) && echo ${temp%/*}
}
