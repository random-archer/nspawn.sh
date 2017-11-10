#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# configuration management
#

# configuration file parser
ns_conf_parse() {
    local "$@" ; ns_log_req file
    false # TODO
}

#
ns_conf_profile_name() {
    local "$@" # id
    echo "${id}.nspawn"
}

# service unit properties
ns_conf_profile_file() {
    local "$@" # id
    echo "${ns_VAL[profile_dir]}/$(ns_conf_profile_name)"
}

ns_conf_service_name() {
    local "$@" # id
    echo "${id}.service"
}
                
# systemd service unit file
ns_conf_service_file() {
    local "$@" # id
    echo "${ns_VAL[service_dir]}/$(ns_conf_service_name)"
}

ns_conf_timer_name() {
    local "$@" # id
    echo "${id}.timer"
}
            
# systemd service unit file
ns_conf_timer_file() {
    local "$@" # id
    echo "${ns_VAL[service_dir]}/$(ns_conf_timer_name)"
}
    
# systemd mount folder
ns_conf_machine_dir() {
    local "$@" # id
    echo "${ns_VAL[machine_dir]}/${id}"
}

# machine resources
ns_conf_runtime_dir() {
    local "$@" # id
    echo "${ns_VAL[runtime_dir]}/${id}"
}

# container settings files
ns_conf_runtime_conf_dir() {
    local "$@" # id
    echo "$(ns_conf_runtime_dir)/${ns_VAL[conf_dir]}"
}

# container root file system
ns_conf_runtime_root_dir() {
    local "$@" # id
    echo "$(ns_conf_runtime_dir)/${ns_VAL[root_dir]}"
}

# container overlay work folder
ns_conf_runtime_work_dir() {
    local "$@" # id
    echo "$(ns_conf_runtime_dir)/${ns_VAL[work_dir]}"
}

# container overlay bottom folder (build)
ns_conf_runtime_zoom_dir() {
    local "$@" # id
    echo "$(ns_conf_runtime_dir)/${ns_VAL[zoom_dir]}"
}

# nspawn.sh container descriptor
ns_conf_runtime_conf_file() {
    local "$@" # id
    echo "$(ns_conf_runtime_conf_dir)/${ns_VAL[conf_file]}"
}

# transient reports
ns_conf_report_dir() {
    echo "$(ns_a_temp_dir)/$(ns_a_prog_sign)"
}
