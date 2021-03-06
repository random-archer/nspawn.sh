#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

source "${BASH_SOURCE%/*}/a.sh"

#test_any() {
#    local any=123
#}
#
#test_logger() {
#    local logger=456
#    test_any
#}

test_ns_log_req() { # no sub shell
    ns_init_all
    ns_trap_init
    ns_log_args
    ns_CONF[log_level]=0
    ns_CONF[dbug_trap_skip_exit]=yes 
    
    local log=$(2>&1 ns_log_req name) # error event
    echo "$log"
    assert_match "$log" "require"
}

test_ns_log_has_color() (
    ns_init_all
    ns_trap_init
    ns_log_args
    ns_CONF[log_level]=5
    ns_log_has_color_caps && echo "ns_log_has_color_caps" || true
    ns_log_has_color_vars && echo "ns_log_has_color_vars" || true
    ns_log_has_no_color_vars && echo "ns_log_has_no_color_vars" || true
    env|sort
)

#test_ns_log_req
test_ns_log_has_color
