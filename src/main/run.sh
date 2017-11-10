#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# user command implementation
#

ns_run_list_archive() {
    :
}

ns_run_list_extract() {
    :
}

ns_run_list_machine() {
    :
}

ns_run_list_network() {
    :
}

ns_run_list_unit() {
    :
}

# install container resource
ns_run_unit_create() { 
    ns_log_info
    local unit="${machine[id]}"
    
    ns_machine_assert_missing
    ns_proxy_create
    ns_image_pull
    ns_resolve_machine
    ns_machine_create
    ns_overlay_delete # mount later by unit start
    ns_unit_resource mode=create
    ns_sys_reload
}

# destroy container resource
ns_run_unit_delete() { 
    ns_log_info
    local unit="${machine[id]}"
    
    ns_machine_assert_present
    ns_unit_resource mode=delete
    ns_machine_delete
    ns_sys_reload
}

# re-create container resource w/o image refresh
ns_run_unit_update() { 
    ns_log_info
    local unit="${machine[id]}"
    
    local active=$(ns_sys_has_active && echo yes || echo no)
    local enabled=$(ns_sys_has_enabled && echo yes || echo no)
    ns_run_unit_erase
    ns_run_unit_ensure
    [[ $active == yes ]] && ns_sys_unit_start || true
    [[ $enabled == yes ]] && ns_sys_unit_enable || true
}

# re-create container resource with image refresh
ns_run_unit_upgrade() { 
    ns_log_info
    local unit="${machine[id]}"
    
    ns_STATE[image_pull_check]=yes # fresh images for upgrade
    ns_run_unit_update
}

#
ns_run_unit_erase() {
    ns_log_info
    local unit="${machine[id]}"
    
    ns_sys_unit_deactivate
    ns_unit_resource mode=delete
    ns_machine_delete
    ns_sys_reload
}

#
ns_run_unit_ensure() {
    ns_log_info
    local unit="${machine[id]}"
    
    ns_machine_has_resource || ns_run_unit_create
}

#
ns_run_unit_launch() {
    ns_log_info
    local unit="${machine[id]}"
    
    ns_run_unit_ensure
    ns_sys_unit_start 
}

#
ns_run_unit_inspire() {
    ns_log_info
    local unit="${machine[id]}"
    
    ns_run_unit_ensure
    ns_sys_unit_activate 
}
