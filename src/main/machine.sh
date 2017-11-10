#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# container management
#

# report live container folders
ns_folder_list_live() {
    ns_log_note
    local list=()
    local dir= ; for dir in $(ns_machine_folder_list) ; do
        [[ -e $dir ]] && list+=("$dir") || continue
    done
    echo "${list[*]-}"
}

# check if container resources are present
ns_machine_has_resource() { 
    [[ $(ns_folder_list_live) ]]
}

ns_machine_assert_present() {
    ns_machine_has_resource || ns_log_fail "machine is missing: id='${machine[id]}'"  
}

ns_machine_assert_missing() {
    ! ns_machine_has_resource || ns_log_fail "machine is present: id='${machine[id]}'"  
}

# defined machine resources
ns_machine_folder_list() { 
    ns_log_note
    local key= ; for key in ${machine[folder_list]-} ; do
        echo "${machine[$key]}"
    done
}

# verify if container resources missing
ns_machine_assert_resource_clean() { 
    ns_log_note
    local list=$(ns_folder_list_live)
    [[ $list ]] || return 0
    ns_log_fail "resource present: ${list[*]-}"
}

ns_machine_resource() {
    local "$@" ; ns_log_req --dbug mode
    local path=; for path in $(ns_machine_folder_list) ; do
       case "$mode" in
           create) ns_a_sudo mkdir -p "$path" ;;
           delete) ns_a_sudo rm -r -f "$path" ;;
           *) false ;; # trap
       esac
    done 
}

# declare container context
ns_machine_declare() {
    ns_log_note
        
    # container properties map
    declare -A machine=() 
    
    # resolution log list
    declare -a machine_log=()
     
    # execution parameters list
    declare -a machine_entry=() 
    
    # overlay image url list, 
    # ordered, full depth, no duplicate 
    declare -a machine_overlay=()
     
    # variable persistence group
    declare -r machine_context=${!machine*} 

    declare -p ${!machine*}
}

# define container resources
ns_machine_define() {
    ns_log_note

    [[ "${ns_STATE[machine_define]}" == yes ]] && ns_log_fail "duplicate" || ns_STATE[machine_define]=yes   

    # unique space: 'url/name'
    local "$@" ; ns_log_req --dbug url name
    
    # assert
    ns_a_has_declare machine
    
     # locally unique machine id
    local id="$name"
    
    # properties
    machine[id]="$id"

    # /etc/systemd/...
    machine[profile_file]=$(ns_conf_profile_file) # service unit properties
    machine[service_file]=$(ns_conf_service_file) # systemd service unit file 
                
    # /var/lib/machines/...
    machine[machine_dir]=$(ns_conf_machine_dir) # systemd mount folder
    
    # /var/lib/nspawn.sh/...
    machine[base_dir]=$(ns_conf_runtime_dir) # machine resources
    machine[conf_dir]=$(ns_conf_runtime_conf_dir) # container settings files
    machine[root_dir]=$(ns_conf_runtime_root_dir) # container root file system
    machine[work_dir]=$(ns_conf_runtime_work_dir) # container overlay work folder
    machine[zoom_dir]=$(ns_conf_runtime_zoom_dir) # container overlay bottom folder (build)
    machine[conf_file]=$(ns_conf_runtime_conf_file) # nspawn.sh container descriptor
    machine[folder_list]="conf_dir root_dir work_dir zoom_dir base_dir machine_dir" # required runtime folders
        
}

# create container resources
ns_machine_create() { 
    ns_log_dbug
    
    ns_machine_resource mode=create
    ns_overlay_create
}

# delete container resources
ns_machine_delete() { 
    ns_log_dbug
    
    ns_overlay_delete
    ns_machine_resource mode=delete

    ns_machine_assert_resource_clean
}
