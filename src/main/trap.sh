#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# signal handler
#

# note:
#   command substitution '$()' does inherit trap
#   full sub shell invocation '()' or 'cmd &' does not inherit trap 

# trap user ctrl-c
ns_trap_on_int() { 
    1>&2 echo # ensure new line
    ns_log_dbug 
    ns_trap_do_interrupt
}

# trap all forms of exit; runs only in main shell; use for cleanup;
ns_trap_on_exit() {
    
    # trapped exit
    local code="$?"
    ns_log_dbug nest=$BASH_SUBSHELL code=$code
    
    # debug trace
    ns_trap_has_do_exit || ns_log_trap type="script error"
    
    # process hooks
    ns_trap_fire_exit
    
    # display final step
    ns_exit state="${ns_STATE[terminate]}" code="$code"
    
}

# trap force terminate
ns_trap_on_term() {
    ns_log_dbug
    
    # terminate process descendants
    kill -KILL $(ps -o pid= --ppid $$) || true
    
    # process hooks
    ns_trap_fire_exit
        
    exit 127
}

# trap script runtime: non-zero return / programming error
ns_trap_on_error() {
    ns_log_dbug
    ns_log_trap type="return value"
    ns_trap_do_error
}

# trap in main shell signal sent from sub shell 
ns_trap_on_sub_error() { 
    ns_log_dbug nest=$BASH_SUBSHELL
    ns_trap_do_error
}

# verify if we are in root shell
ns_trap_has_main() {
    [[ $BASH_SUBSHELL == 0 ]]
}

# send error signal from sub shell to main shell
ns_trap_send_sub_error() { 
    ns_log_dbug nest=$BASH_SUBSHELL
    if ns_trap_has_main ; then
        ns_log_note "no parent"
        return 0
    else
        ns_log_note "send to parent"
        kill -s USR1 $$
    fi
}

# process 'exit' hooks
ns_trap_fire_exit() {
    local entry=; for entry in "${ns_trap_HOOK_EXIT[@]-}" ; do
        local header=${entry%% *} # parse command
        ns_log_note "$header" # report command
        $entry # invoke hook
    done
}

# FIXME unused
# terminate with success
ns_trap_do_exit() {
    local "$@"
    ns_log_dbug
    ns_trap_terminate state="ok" code=0
}

# terminate shell with error
ns_trap_do_error() {
    ns_log_dbug nest=$BASH_SUBSHELL
    ns_trap_send_sub_error # propagate
    ns_trap_terminate state="error" code=101
}

# terminate shell from user input
ns_trap_do_interrupt() { 
    ns_log_dbug 
    ns_trap_terminate state="interrupt" code=102
}

# detect if exit is trap-initiated
ns_trap_has_do_exit() {
    local "$@" # code
    [[ $code == 0 || $code == 101 || $code == 102 ]]
}

# program real exit
ns_trap_terminate() {
    ns_log_dbug nest=$BASH_SUBSHELL
    local "$@" # state code
    ns_STATE[terminate]="$state"
    
    # developer mode
    if [[ ${ns_CONF[dbug_trap_skip_exit]} == yes ]] ; then
        ns_log_dbug "dbug_trap_skip_exit"
        return 0
    fi
    
    # program real exit
    exit $code
}

# setup interrupt
ns_trap_init() {
    ns_log_dbug nest=$BASH_SUBSHELL
    
    # signal handler
    trap ns_trap_on_int INT # user crtl+c
    trap ns_trap_on_exit EXIT # script terminate
#    trap ns_trap_on_term TERM # script force terminate
    trap ns_trap_on_error ERR # script logic errors
    trap ns_trap_on_sub_error USR1 # inter-shell signal

    # 'exit' event listeners
    declare -g -a ns_trap_HOOK_EXIT=()
}

# register 'exit' event handler
ns_trap_hook_exit() {
    local "$@" # entry
    ns_trap_HOOK_EXIT+=("$entry")    
}
