#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
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

ns_run_unit_enable() { # enable service
    ns_log_info
#    ns_machine_assert_present
    local service="${machine[id]}"
    &> /dev/null ns_sys_ctl is-enabled "$service" || ns_sys_ctl enable "$service"
}

ns_run_unit_disable() { # disable service
    ns_log_info
#    ns_machine_assert_present
    local service="${machine[id]}"
    &> /dev/null ns_sys_ctl is-enabled "$service" && ns_sys_ctl disable "$service" || true
}

ns_run_unit_start() { # start service
    ns_log_info
#    ns_machine_assert_present
    local service="${machine[id]}"
    &> /dev/null ns_sys_ctl is-active "$service" || ns_sys_ctl start "$service"
}

ns_run_unit_stop() { # stop service
    ns_log_info
#    ns_machine_assert_present
    local service="${machine[id]}"
    &> /dev/null ns_sys_ctl is-active "$service" && ns_sys_ctl stop "$service" || true
}

# install container resource
ns_run_unit_create() { 
    ns_log_info
    ns_machine_assert_missing
    ns_proxy_create
    ns_image_pull
    ns_resolve_machine
    ns_machine_create
    ns_overlay_delete # mount later by unit start
    ns_unit_resource mode=create
    ns_unit_reload
}

# destroy container resource
ns_run_unit_delete() { 
    ns_log_info
    ns_machine_assert_present
    ns_unit_resource mode=delete
    ns_machine_delete
    ns_unit_reload
}

# re-create container resource w/o image refresh
ns_run_unit_update() { 
    ns_log_info
    local service="${machine[id]}"
    local active=$(ns_sys_ctl is-active "$service" && echo yes || echo no)
    local enabled=$(ns_sys_ctl is-enabled "$service" && echo yes || echo no)
    ns_run_unit_erase
    ns_run_unit_ensure
    [[ $active == "yes" ]] && ns_run_unit_start || true
    [[ $enabled == "yes" ]] && ns_run_unit_enable  || true
}

# re-create container resource with image refresh
ns_run_unit_upgrade() { 
    ns_STATE[image_pull_check]=yes # fresh images for upgrade
    ns_run_unit_update
}

ns_run_unit_erase() { #
    ns_log_info
    ns_run_unit_stop
    ns_run_unit_disable
    ns_unit_resource mode=delete
    ns_machine_delete
    ns_unit_reload
}

ns_run_unit_ensure() { #
    ns_log_info
    ns_machine_has_resource || ns_run_unit_create
}

ns_run_unit_launch() { #
    ns_log_info
    ns_run_unit_ensure
    ns_run_unit_start 
}

ns_run_unit_inspire() { #
    ns_log_info
    ns_run_unit_ensure
    ns_run_unit_enable 
    ns_run_unit_start 
}
