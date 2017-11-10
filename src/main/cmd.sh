#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# public build commands
#

CONFIG() {
    [[ ${ns_STATE[cmd_image]} == no ]] || ns_log_fail "CONFIG after IMAGE"
    ns_STATE[do_config]=yes
    ns_log_args "$@" ; ns_a_args_assert "$@" ; ns_do_config "$@"
}

IMAGE() {
    [[ ${ns_STATE[cmd_image]} == no ]] || ns_log_fail "IMAGE after IMAGE"
    ns_STATE[cmd_image]=yes
    ns_log_args "$@" ; ns_a_args_assert "$@" ; ns_do_image "$@"
}

PULL() {
    [[ ${ns_STATE[cmd_image]} == yes ]] || ns_log_fail "PULL before IMAGE"
    [[ ${ns_STATE[cmd_alter]} == no ]] || ns_log_fail "PULL after ALTER"
    [[ ${ns_STATE[cmd_push]} == no ]] || ns_log_fail "PULL after PUSH"
    [[ ${ns_STATE[cmd_run]} == no ]] || ns_log_fail "PULL after RUN"
    ns_STATE[do_pull]=yes
    ns_log_args "$@" ; ns_a_args_assert "$@" ; ns_do_pull "$@"
}

COPY() {
    [[ ${ns_STATE[cmd_image]} == yes ]] || ns_log_fail "COPY before IMAGE"
    ns_STATE[cmd_alter]=yes
    ns_log_args "$@" ; ns_a_args_assert "$@" ; 
    local path=; local "$@" # keep order 
    if [[ $path ]] ; then
        local entry= ; for entry in ${path//':'/' '} ; do 
            ns_do_copy src="$entry" dst="$entry"
        done
    else
        ns_do_copy "$@"
    fi
}

DEF() {
    [[ ${ns_STATE[cmd_image]} == yes ]] || ns_log_fail "DEF before IMAGE"
    ns_STATE[cmd_alter]=yes
    ns_log_args "$@" ; ns_a_args_assert "$@" ; local "$@"
    
    # text variable or here-doc definition
    local here= ; ns_a_define here
    
    # choose text file content
    local body=
    if [[ ${text-} && ! ${here-} ]] ; then
        body="$text"
    elif [[ ! ${text-} && ${here-} ]] ; then
        body="$here"
    else
        ns_log_fail "use only one of: 'text=...' or '<< EOF'"
    fi
        
    ns_do_def path="$path" text="$body"
}

GET() {
    [[ ${ns_STATE[cmd_image]} == yes ]] || ns_log_fail "GET before IMAGE"
    ns_STATE[cmd_alter]=yes
    ns_log_args "$@" ; ns_a_args_assert "$@" ; ns_do_get "$@"
}

# after image

ENV() {
    [[ ${ns_STATE[cmd_image]} == yes ]] || ns_log_fail "ENV before IMAGE"
    [[ ${ns_STATE[cmd_run]} == no ]] || ns_log_fail "ENV after RUN"
    ns_STATE[cmd_alter]=yes
    ns_log_args "$@" ; ns_a_args_assert "$@" ; ns_do_env "$@"
}

CAP() {
    [[ ${ns_STATE[cmd_image]} == yes ]] || ns_log_fail "CAP before IMAGE"
    [[ ${ns_STATE[cmd_run]} == no ]] || ns_log_fail "CAP after RUN"
    ns_STATE[cmd_alter]=yes
    ns_log_args "$@" ; ns_a_args_assert "$@" ; ns_do_cap "$@"
}

EXEC() {
    [[ ${ns_STATE[cmd_image]} == yes ]] || ns_log_fail "EXEC before IMAGE"
    [[ ${ns_STATE[cmd_run]} == no ]] || ns_log_fail "EXEC after RUN"
    ns_STATE[cmd_alter]=yes
    ns_log_args "$@" ; ns_do_exec "$@"
}

INIT() {
    [[ ${ns_STATE[cmd_image]} == yes ]] || ns_log_fail "INIT before IMAGE"
    [[ ${ns_STATE[cmd_run]} == no ]] || ns_log_fail "INIT after RUN"
    ns_STATE[cmd_alter]=yes
    ns_log_args "$@" ; ns_do_init "$@"
}

PROF() {
    [[ ${ns_STATE[cmd_image]} == yes ]] || ns_log_fail "PROF before IMAGE"
    [[ ${ns_STATE[cmd_run]} == no ]] || ns_log_fail "PROF after RUN"
    ns_STATE[cmd_alter]=yes
    ns_log_args "$@" ; ns_a_args_assert "$@" ; ns_do_prof "$@"
}

UNIT() {
    [[ ${ns_STATE[cmd_image]} == yes ]] || ns_log_fail "UNIT before IMAGE"
    [[ ${ns_STATE[cmd_run]} == no ]] || ns_log_fail "UNIT after RUN"
    ns_STATE[cmd_alter]=yes
    ns_log_args "$@" ; ns_a_args_assert "$@" ; ns_do_unit "$@"
}

#---

RUN() {
    [[ ${ns_STATE[cmd_image]} == yes ]] || ns_log_fail "RUN before IMAGE"
    ns_STATE[cmd_alter]=yes
    ns_STATE[cmd_run]=yes
    ns_log_args "$@"
    ns_do_run_lazy "$@"
}

RUN!() {
    [[ ${ns_STATE[cmd_image]} == yes ]] || ns_log_fail "RUN before IMAGE"
    ns_STATE[cmd_alter]=yes
    ns_STATE[cmd_run]=yes
    ns_log_args "$@"
    ns_do_run_avid "$@"
}

SH() {
    [[ ${ns_STATE[cmd_image]} == yes ]] || ns_log_fail "SH before IMAGE"
    ns_STATE[cmd_alter]=yes
    ns_STATE[cmd_run]=yes
    ns_log_args "$@" 
    local shell=${ns_CONF[run_shell]}
    ns_do_run_lazy $shell -c "$*"
}

SH!() {
    [[ ${ns_STATE[cmd_image]} == yes ]] || ns_log_fail "SH before IMAGE"
    ns_STATE[cmd_alter]=yes
    ns_STATE[cmd_run]=yes
    ns_log_args "$@"
    local shell=${ns_CONF[run_shell]}
    ns_do_run_avid $shell -c "$*"
}

#

PUSH() {
    [[ ${ns_STATE[cmd_image]} == yes ]] || ns_log_fail "PUSH before IMAGE"
    [[ ${ns_STATE[cmd_push]} == no ]] || ns_log_fail "PUSH after PUSH"
    ns_STATE[cmd_push]=yes
    ns_log_args "$@" ; ns_a_args_assert "$@" ; ns_do_push "$@"
}
