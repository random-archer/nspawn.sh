#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

#
# build command implementation
#

# change global config
ns_do_config() { 
    ns_log_info
    
    # known config keys
    local list="${!ns_CONF[@]}"
    
    local key= value= 
    local entry= ; for entry in "$@" ; do
        # have key=value ?
        [[ $entry == *"="* ]] || continue
        
        # have known config key ?
        key="${entry%%=*}" ; value="${entry#*=}" 
        [[ $list == *"$key"* ]] || continue
        
        # store in config
        ns_CONF[$key]="$value"
        ns_log_info "apply: $key='$value'"
    done
}

# build first step
ns_do_image() { 
    ns_log_info
    local "$@" ; ns_log_req url

    local machine_id=$(ns_a_prog_name)-$(ns_a_guid_char)
            
    ns_image_define # url
    
    ns_machine_define name="$machine_id"
    
    ns_proxy_create

    # serialize execution context
    local context=; printf -v context "%q" "$(declare -p image machine)"

    # store cleanup pre-build  
    ns_build_reset url="${image[url]}"
    
    # store cleanup post-build
    ns_trap_hook_exit entry="ns_do_exit context=$context"
    
}

# last step in build, invoked from exit trap
ns_do_exit() {
    ns_log_dbug
        
    [[ ${ns_STATE[do_exit]} == yes ]] && return 0 ; ns_STATE[do_exit]=yes

    # de-serialize execution context
    eval "$@" ; eval "$context" # => image machine
    
    ns_build_delete url="${image[url]}"
    
    ns_proxy_delete
}


ns_do_pull() {
    ns_log_info
    local "$@" ; ns_log_req url
    
    ns_image_pull
    
    ns_image_append_overlay entry="$url"
}

ns_do_copy() {
    ns_log_info
    local "$@" ; ns_log_req src dst
    
    local base_dir="${ns_CONF[base_dir]}" 
    local root_dir="${machine[root_dir]}"
    
    local source="$base_dir/$src" 
    local target="$root_dir/$dst"
    
    [[ -e "$source" ]] || ns_log_fail "missing source '$source'" 
    
    # rsync convention for folders
    [[ -d "$source" && "$source" =~ ^.*/$ ]] || source="$source/" 
    
    ns_log_dbug "$source -> $target"
    
    ns_a_mkpar file="$target"
    
    ns_a_sudo rsync -a --no-o --no-g "$source" "$target"
}

ns_do_def() {
    ns_log_info
    local "$@" ; ns_log_req path text
    
    path="${path#/}"
    local root_dir=${machine[root_dir]}
    local file="$root_dir/$path"
    ns_log_info "provision '$file'"
    echo "$text" | ns_a_save
}

ns_do_get() {
    false # TODO
}

ns_do_env() {
    ns_log_info
    local entry= ; for entry in "$@" ; do
        # inject in build
        declare -g "$entry"
        # inject in profile 
        ns_do_set "Environment=\"$entry\"" # must quote
    done
}

ns_do_cap() {
    ns_log_info
    local "$@" ; 
    [[ "$add" ]] && { ns_do_set Capability="$add" ; return 0 ;}
    [[ "$rem" ]] && { ns_do_set DropCapability="$rem" ; return 0 ;}
    ns_log_fail "invalid command"
}

ns_do_exec() {
    ns_log_info
    ns_do_set Boot="no" Parameters="$*" KillSignal="TERM"
}

ns_do_init() {
    ns_log_info
    ns_do_set Boot="yes" Parameters="$*" # render parameters
}

ns_do_set() {
    ns_log_info
    local entry= ; for entry in "$@" ; do
        # comment re-write
        [[ "$entry" =~ ^_=* ]] && entry="# ${entry#_=}"
        # persist configuration value
        ns_image_append_entry entry="$entry"
    done
}

# invoke nspawn
ns_do_run() {
    ns_log_info

    ns_build_create
    
    local machine=${machine[id]}
    
    ns_a_sudo systemd-nspawn --quiet --machine "$machine" "$@" || ns_log_fail "systemd-nspawn failure" 
}

# run only one time during multiple build sessions
ns_do_run_once() {
    ns_log_info
        
    local url="${image[url]}"
    
    # url => store_*
    eval "$(ns_store_space)" # url
        
    # persisted build state folder
    local data_dir="${store_extract}${ns_VAL[build_data]}"
    
    # run once state folder
    local once_dir="$data_dir/run_once"
    
    # ensure folder present
    ns_a_mkdir dir="$once_dir"
    
    # make command digest
    local once_hash=$(ns_a_text_hash text="$*")
    
    # locate memento file
    local once_file="$once_dir/$once_hash"
    
    if [[ -e $once_file ]] ; then
        ns_log_dbug "already invoked"
        return 0
    else
        ns_log_dbug "apply invocation"
        ns_do_run "$@" # must return ok 
        echo "$@" | ns_a_save file="$once_file"
        ns_do_sync # persist change after run
    fi
}

# copy files form root fs into extact
ns_do_sync() {
    local "$@" #; ns_log_req --info url
        
    # machine transient runtime root fs
    local root_dir=${machine[root_dir]}

    local url=${image[url]}

    # url => store_*
    eval "$(ns_store_space)"
    
    # ensure copy target
    ns_a_mkdir dir="$store_extract"
    
    # transfer from transient to permanent store 
    ns_a_sudo rsync -a "$root_dir"/ "$store_extract"
}

# 
ns_do_push() {
    ns_log_info
    local "$@" ;

    local url=${image[url]}

    # copy files form root fs into extact
    ns_do_sync # url
    
    # transform: extract => archive => server 
    ns_image_push # url
}

# upload current layer only
ns_do_push_default() {
    false # TODO
}

# flatten all overlays into one
ns_do_push_flatten() { 
    false # TODO
}

# protect commands
ns_do_cmd_lock() {
    local IFS=$'\n'
    local decl="declare -f " # report prefix
    local regx="$decl[A-Z]+" # upper case func names
    local func=;
    local line=; for line in $(declare -F) ; do
        [[ $line =~ $regx ]] || continue
        func=${line##$decl}
        declare -f -r "$func" # make read only
    done
}
