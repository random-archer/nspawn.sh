#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

source "${BASH_SOURCE%/*}/a.sh"

test_cmd_DEF_1() (
    ns_init_all
    ns_log_args
    eval "$(ns_image_declare)"
    eval "$(ns_machine_declare)"
    # build script
    IMAGE url="http://host/path/${FUNCNAME}"
    local root_dir="${machine[root_dir]}"
    local path1="/etc/test1.conf" 
    local path2="/etc/test2.conf"
    # define in-line
DEF path="$path1" text="a=1"
    # verify content
    assert_equal_file "$root_dir/$path1" "a=1"
    # define multi-file
    local var=2   
DEF path=$path2 << EOF
a=1
b=$(( var + 3 ))
EOF
    # verify content
    assert_equal_file "$root_dir/$path2" "$(printf 'a=1\nb=5\n')"    
)

test_cmd_DEF_2() (
    ns_init_all
    ns_log_args
    local secret=$(ns_a_guid)
    eval "$(ns_image_declare)"
    eval "$(ns_machine_declare)"
    # override handler
    ns_trap_send_sub_error() { echo "$secret" ; }
    # build script
    IMAGE url="http://host/path/${FUNCNAME}"
    local root_dir="${machine[root_dir]}"
    # must fail
    local capture=$(
DEF path="/tmp/invalid" text="hello" << EOF
hello kitty
EOF
    )
    #echo capture=capture
    assert_equal "$capture" "$secret"
)

test_cmd_DEF_1
test_cmd_DEF_2
