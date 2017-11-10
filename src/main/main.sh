#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
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
    ns_log_dbug
    
    # parse invoke: 'bash nspawn.sh build.sh [args]'
    local build="$1"
    shift 1

    # apply config entries    
    ns_a_args_assert "$@"
    ns_do_config "$@"
    
    # fresh images for build
    ns_STATE[image_pull_check]=yes
    
    # folder containing 'build.sh' script
    ns_CONF[base_dir]=$(ns_a_path_dir path="$build")
        
    # root context
    eval "$(ns_image_declare)"
    eval "$(ns_machine_declare)"
     
    # execute build script
    source "$build" 
}

# user command mode
ns_main_command() {
    ns_log_dbug
    
    # apply config entries    
    ns_a_args_assert "$@"
    ns_do_config "$@"

    # inject arguments
    eval "$(ns_parse_to_map "$@")"
    local run=${map[run]-} 
        
    # parse run statement command and action
    [[ $run ]] || ns_log_fail "missing 'run' statement"
    local command=${run%%/*} action=${run##*/}
    
    case "$command" in
        h*) # help
            ns_log_args "$(ns_help_text)" ;;
        li*) # list 
            case "$action" in
                ne*) ns_run_list_network ;;
                ma*) ns_run_list_machine ;; un*) ns_run_list_unit ;;
                ar*) ns_run_list_archive ;; ex*) ns_run_list_extract ;; 
                *) ns_log_fail "wrong 'list' action '$action', $(ns_main_tip)" ;;
            esac ;;
        ke*) # keep
            case "$action" in
                cl*) ns_keep_cmd_clean ;;
                ins*) ns_keep_cmd_install ;;
                rem*) ns_keep_cmd_remove ;;
                *) ns_log_fail "wrong 'keep' action '$action', $(ns_main_tip)" ;;
            esac ;;
        un*) # unit
            
            #
            local name=${map[name]-} 
            [[ $name ]] || ns_log_fail "missing machine 'name'"
            local url=${map[url]-} 
            [[ $url ]] || ns_log_fail "missing image 'url'"
                
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
    # match:
    local line=$(file -b "$1")
    # 'Bourne-Again shell script, ASCII text executable'
    [[ $line =~ shell && $line =~ script && $line =~ text ]]
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
ns_main_deps_apply() { # list
    &>/dev/null type -p "$entry" || list+=("$entry")
}

# verify dependencies 
ns_main_deps_assert() {
    # required
    local list=()
    ns_a_list_apply list=ns_main_REQUIRED apply=ns_main_deps_apply
    [[ ! ${list[@]-} ]] || ns_log_fail "missing required programs: ${list[*]}"
    # optional
    local list=()
    ns_a_list_apply list=ns_main_OPTIONAL apply=ns_main_deps_apply
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

    # signal handler
    ns_trap_init
    
    # prerequisites
    ns_main_bash_assert
    ns_main_deps_assert
    ns_main_sudo_assert
    
    # report arguments    
    ns_log_args "$(ns_a_prog_sign)" "$@"
    
    # program mode
    if [[ "0" == "$#" ]] ; then
        # invalid input
        ns_STATE[main]="help" 
        ns_help_text
    elif [[ "---" == "$1" ]] ; then
        # developer mode
        ns_STATE[main]="test" 
    elif ns_main_has_script "$1" ; then
        # build image
        ns_STATE[main]="build" 
        ns_main_build "$@"
    else
        # manage container
        ns_STATE[main]="command" 
        ns_main_command "$@"
    fi 
}
