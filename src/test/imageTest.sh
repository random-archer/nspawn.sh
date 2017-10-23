#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

source "${BASH_SOURCE%/*}/a.sh"

test_ns_image_declare() (
    ns_init_all
    ns_log_args
    ! ns_a_has_declare image 
    eval "$(ns_image_declare)"
    ns_a_has_declare image 
    declare -p ${!image*} 
)

test_ns_image_define() (
    ns_init_all
    ns_log_args
    eval "$(ns_image_declare)" 
    local url="http://user:pass@host/path/file?q1=a1&q2=b2#f1=c1&f2=d2"
    ns_image_define
    declare -p ${!image*}
    assert_equal "$url" "${image[url]}" 
)

test_ns_image_declare
test_ns_image_define
