#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

#
# public build commands
#

CONFIG() {
    [[ ${ns_STATE[do_image]} == no ]] || ns_log_fail "CONFIG after IMAGE"
    ns_STATE[do_config]=yes
    ns_log_args "$@" ; ns_a_args_assert "$@" ; ns_do_config "$@"
}

IMAGE() {
    [[ ${ns_STATE[do_image]} == no ]] || ns_log_fail "IMAGE after IMAGE"
    ns_STATE[do_image]=yes
    ns_log_args "$@" ; ns_a_args_assert "$@" ; ns_do_image "$@"
}

PULL() {
    [[ ${ns_STATE[do_image]} == yes ]] || ns_log_fail "PULL before IMAGE"
    [[ ${ns_STATE[do_alter]} == no ]] || ns_log_fail "PULL after ALTER"
    [[ ${ns_STATE[do_push]} == no ]] || ns_log_fail "PULL after PUSH"
    ns_STATE[do_pull]=yes
    ns_log_args "$@" ; ns_a_args_assert "$@" ; ns_do_pull "$@"
}

COPY() {
    [[ ${ns_STATE[do_image]} == yes ]] || ns_log_fail "COPY before IMAGE"
    ns_STATE[do_alter]=yes
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
    [[ ${ns_STATE[do_image]} == yes ]] || ns_log_fail "DEF before IMAGE"
    ns_STATE[do_alter]=yes
    ns_log_args "$@" ; ns_a_args_assert "$@" ; local "$@"
    [[ ${text-} ]] || { local text= ; ns_a_define text ; } # optional in-line text
    ns_do_def path="$path" text="$text"
}

GET() {
    [[ ${ns_STATE[do_image]} == yes ]] || ns_log_fail "GET before IMAGE"
    ns_STATE[do_alter]=yes
    ns_log_args "$@" ; ns_a_args_assert "$@" ; ns_do_get "$@"
}

#---

ENV() {
    [[ ${ns_STATE[do_image]} == yes ]] || ns_log_fail "ENV before IMAGE"
    [[ ${ns_STATE[do_run]} == no ]] || ns_log_fail "ENV after RUN"
    ns_STATE[do_alter]=yes
    ns_log_args "$@" ; ns_a_args_assert "$@" ; ns_do_env "$@"
}

CAP() {
    [[ ${ns_STATE[do_image]} == yes ]] || ns_log_fail "CAP before IMAGE"
    [[ ${ns_STATE[do_run]} == no ]] || ns_log_fail "CAP after RUN"
    ns_STATE[do_alter]=yes
    ns_log_args "$@" ; ns_a_args_assert "$@" ; ns_do_cap "$@"
}

EXEC() {
    [[ ${ns_STATE[do_image]} == yes ]] || ns_log_fail "EXEC before IMAGE"
    [[ ${ns_STATE[do_run]} == no ]] || ns_log_fail "EXEC after RUN"
    ns_STATE[do_alter]=yes
    ns_log_args "$@" ; ns_do_exec "$@"
}

INIT() {
    [[ ${ns_STATE[do_image]} == yes ]] || ns_log_fail "INIT before IMAGE"
    [[ ${ns_STATE[do_run]} == no ]] || ns_log_fail "INIT after RUN"
    ns_STATE[do_alter]=yes
    ns_log_args "$@" ; ns_do_init "$@"
}

SET() {
    [[ ${ns_STATE[do_image]} == yes ]] || ns_log_fail "SET before IMAGE"
    [[ ${ns_STATE[do_run]} == no ]] || ns_log_fail "SET after RUN"
    ns_STATE[do_alter]=yes
    ns_log_args "$@" ; ns_a_args_assert "$@" ; ns_do_set "$@"
}

#---

ONCE() {
    [[ ${ns_STATE[do_image]} == yes ]] || ns_log_fail "ONCE before IMAGE"
    ns_STATE[do_alter]=yes
    ns_STATE[do_run]=yes
    ns_log_args "$@"
    ns_do_run_once "$@"
}

RUN() {
    [[ ${ns_STATE[do_image]} == yes ]] || ns_log_fail "RUN before IMAGE"
    ns_STATE[do_alter]=yes
    ns_STATE[do_run]=yes
    ns_log_args "$@"
    ns_do_run "$@"
}

SH() {
    [[ ${ns_STATE[do_image]} == yes ]] || ns_log_fail "SH before IMAGE"
    ns_STATE[do_alter]=yes
    ns_STATE[do_run]=yes
    ns_log_args "$@" 
    ns_do_run /usr/bin/env sh -c "$*"
}

PUSH() {
    [[ ${ns_STATE[do_image]} == yes ]] || ns_log_fail "PUSH before IMAGE"
    [[ ${ns_STATE[do_push]} == no ]] || ns_log_fail "PUSH after PUSH"
    ns_STATE[do_push]=yes
    ns_log_args "$@" ; ns_a_args_assert "$@" ; ns_do_push "$@"
}
