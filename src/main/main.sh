#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

#
# program main function
#

#
ns_main_tip() {
    echo "try: '$(ns_a_prog_name) run=help'"
}

# configure logger file for 'set -x' traces
ns_main_setup_debug() {
    false # TODO
    # trace output
    local file="${BASH_SOURCE%/*}/trace.log"
    # bind file to descriptor
    exec {fd}<>"$file"
    # redirect trace output to file
    BASH_XTRACEFD="$fd"
    # log line numbers in the trace
    PS4='$LINENO: '
}

# build script mode
ns_main_build() {
    ns_log_note
    local build="$1" ; shift 
    
    #ns_a_args_assert "$@" 
    #local "$@" ; ns_do_config # XXX
    
    # fresh images for build
    ns_STATE[image_pull_check]=yes
    
    # folder containing 'build.sh' script
    ns_CONF[base_dir]=$(ns_a_path_dir path="$build")
        
    # root context
    eval "$(ns_image_declare)"
    eval "$(ns_machine_declare)"
     
    source "$build" # execute build script
}

# user command mode
ns_main_command() {
    ns_log_note
    
    ns_a_args_assert "$@"
     
    ns_do_config "$@"
    
    #ns_log_req run
    
    local "$@"
    
    local command=${run%%/*} action=${run##*/}
    
    case "$command" in
        h*) # help
            ns_log_args "$(ns_help_text)" ;;
        li*) # list 
            case "$action" in
                ne*) ns_run_list_network ;;
                ma*) ns_run_list_machine ;; un*) ns_run_list_unit ;;
                ar*) ns_run_list_archive ;; ex*) ns_run_list_extract ;; 
                *) ns_log_fail "wrong 'list' action '$action', , $(ns_main_tip)" ;;
            esac ;;
        un*) # unit
            local $(ns_unit_args)
            # root context
            eval "$(ns_image_declare)"
            eval "$(ns_machine_declare)"
            ns_image_define # url
            ns_machine_define # name
            #
            case "$action" in
                ens*) ns_run_unit_ensure ;; era*) ns_run_unit_erase ;; 
                lau*) ns_run_unit_launch ;; ins*) ns_run_unit_inspire ;;  
                cre*) ns_run_unit_create ;; del*) ns_run_unit_delete ;; 
                upd*) ns_run_unit_update ;; upg*) ns_run_unit_upgrade ;;
                ena*) ns_run_unit_enable ;; dis*) ns_run_unit_disable ;;
                sta*) ns_run_unit_start  ;; sto*) ns_run_unit_stop ;;
                *) ns_log_fail "wrong 'unit' action '$action', $(ns_main_tip)" ;;
            esac ;;
        *) ns_log_fail "wrong command '$command', $(ns_main_tip)" ;;
    esac
}

# detect if invoked from a build file
ns_main_has_script() { 
    local line=$(file -b "$1")
    [[ $line =~ shell && $line =~ scrip && $line =~ text ]]
}

# verify shell interpreter
ns_main_bash_assert() {
    local major=${BASH_VERSINFO[0]}
    local minor=${BASH_VERSINFO[1]}
    if (( major >= 4 )) && (( minor >= 4 )) ; then
        return 0
    else
        ns_log_fail "$(ns_a_prog_name) requires bash version >= 4.4 current version is: $BASH_VERSION"
    fi
}

# verify dependencies 
ns_main_deps_apply() { 
    &> /dev/null type -p "$entry" || list+=("$entry")
}

# verify dependencies 
ns_main_deps_assert() {
    
    local required=( # required dependency
        sudo md5sum mkdir rm dd file grep sed tar gzip mktemp
        host netcat curl rsync systemd-nspawn systemctl mount umount
    ) 

    local optional=( # optional dependency
        pigz 7z nsenter # s3-get s3-put
    ) 
    
    local list=()
    ns_a_list_apply list=required apply=ns_main_deps_apply
    [[ ! ${list[@]-} ]] || ns_log_fail "missing required programs: ${list[*]}"
    
    local list=()
    ns_a_list_apply list=optional apply=ns_main_deps_apply
    [[ ! ${list[@]-} ]] || ns_log_warn "missing optional programs: ${list[*]}"
    
}

# verify sudo access
ns_main_sudo_assert() {
    ns_a_sudo bash -c "echo > /dev/null" || ns_log_fail "error: can not run sudo"
}

# program exit point
ns_exit() {
    local "$@" # state code
    # display final step
    ns_log_args "$@"
}

# program entry point
ns_main() {
    
    ns_trap_init
    ns_do_cmd_lock
    
    ns_main_bash_assert
    ns_main_deps_assert
    ns_main_sudo_assert
    
    ns_log_args "$(ns_a_prog_version)" "$@" # XXX
        
    if [[ "0" == "$#" ]] ; then
        ns_STATE[main]="none" # invalid
        ns_help_text
    elif [[ "---" == "$1" ]] ; then
        ns_STATE[main]="test" # development
    elif ns_main_has_script "$1" ; then
        ns_STATE[main]="build" # build image
        ns_main_build "$@"
    else
        ns_STATE[main]="command" # manage container
        ns_main_command "$@"
    fi 
}
