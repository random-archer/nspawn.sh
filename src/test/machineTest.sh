#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

source "${BASH_SOURCE%/*}/a.sh"

test_ns_machine_declare() (
    ns_init_all
    ns_log_args
    ! ns_a_has_declare machine 
    eval "$(ns_machine_declare)"
    ns_a_has_declare machine
    declare -p ${!machine*} 
)

test_ns_machine_define() (
    ns_init_all
    ns_log_args
    eval "$(ns_machine_declare)" 
    local name=$(ns_a_guid)
    local url="http://user:pass@host/path/file?q1=a1&q2=b2#f1=c1&f2=d2"
    ns_machine_define # name
    declare -p ${!machine*}
    assert_equal "$name" "${machine[id]}" 
)

test_ns_machine_declare
test_ns_machine_define
