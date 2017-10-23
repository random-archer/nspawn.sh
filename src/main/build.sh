#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

#
# image build operations
#

# detect if context refers to build image
#ns_build_has_self() {
#    ns_log_note "$url"
#    [[ ${ns_STATE[main]} == "build" && $url == ${image[url]} ]]
#}

# keep only build time entries
ns_build_filter() { 
    local build_entry=() 
    local filter_regex="${ns_VAL[prof_build_filter]}"

    ns_a_has_declare machine_entry
            
    local entry= ; for entry in "${machine_entry[@]-}" ; do
        [[ $entry =~ $filter_regex ]] && entry="#build-ignore# $entry"
        build_entry+=("$entry")
    done
    
    # replace with filtered array
    machine_entry=("${build_entry[@]-}")
}

ns_build_mode_create() {
    echo "create"
}

# import machine env vars into build script environment
ns_build_enviro() {
    
    [[ ${ns_CONF[build_import_env]} == yes ]] || return 0
    
    local enviro_regex="^Environment=.+$"
    local entry= ; for entry in "${machine_entry[@]-}" ; do
        [[ $entry =~ $enviro_regex ]] || continue
        eval "$(ns_parse_enviro)" # entry => key,value
        declare -g $key="$value" # import global
    done
}

# provide build container
ns_build_create() {
    local "$@" ; ns_log_req --dbug image
    
    [[ ${ns_STATE[build_create]} == yes ]] && return 0 || ns_STATE[build_create]=yes
    
    local url="${image[url]}" 
    
    # url => store_*
    eval "$(ns_store_space)"
     
    ns_image_push_config
    ns_resolve_machine
    ns_build_filter
    ns_build_enviro
    
    # folders and overlay
    ns_machine_create
    
    # unit.nspawn and unit.service
    ns_unit_resource mode=$(ns_build_mode_create)
}

ns_build_mode_delete() {
    [[ ${ns_CONF[build_unit_keep]} == yes ]] && echo "skip" || echo "delete"
}

# destroy build container
ns_build_delete() { 
    local "$@" ; ns_log_req --dbug image

    [[ ${ns_STATE[build_delete]} == yes ]] && return 0 || ns_STATE[build_delete]=yes
    
    local url="${image[url]}" 
        
    # url => store_*
    eval "$(ns_store_space)"
                                
    # unit.nspawn and unit.service
    ns_unit_resource mode=$(ns_build_mode_delete)
    
    # folders and overlay
    ns_machine_delete
}

# remove build results before build session
ns_build_reset() {
    local "$@" ; ns_log_req --dbug image
    
    [[ ${ns_CONF[build_store_reset]} == yes ]] || return 0
    
    local url="${image[url]}" 
        
    # url => store_*
    eval "$(ns_store_space)"
        
    ns_a_rmdir dir="$store_archive"
    ns_a_rmdir dir="$store_extract"
}
