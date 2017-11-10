#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

source "${BASH_SOURCE%/*}/a.sh"

test_ns_url_parse_1() (
    ns_init_all
    ns_log_args
    local url="http://user:pass@host/path/file?q1=a1&q2=b2#f1=c1&f2=d2"
    eval "$(ns_url_parse)" ; # local
    assert_equal "$url_scheme" "http" 
    assert_equal "$url_user" "user"
    assert_equal "$url_pass" "pass" ;
    assert_equal "$url_host" "host"
    assert_equal "$url_port" "80" ; 
    assert_equal "$url_path" "/path/file"
    assert_equal "$url_query" "q1=a1&q2=b2" # no quotes
    assert_equal "$url_fragment" "f1=c1&f2=d2" # no quotes
    local $(ns_url_parse_query) ; # local
    assert_equal "$q1" "a1"
    assert_equal "$q2" "b2" ;  
    local $(ns_url_parse_fragment) ; # local
    assert_equal "$f1" "c1"
    assert_equal "$f2" "d2" ;  
)

test_ns_url_parse_2() (
    ns_init_all
    ns_log_args
    local url="file:///path/file#type=abc"
    eval "$(ns_url_parse)" ; # local
    assert_equal "$url_scheme" "file" 
    assert_equal "$url_user" ""
    assert_equal "$url_pass" ""
    assert_equal "$url_host" ""
    assert_equal "$url_port" "" ; 
    assert_equal "$url_path" "/path/file"
    assert_equal "$url_query" "" # 
    assert_equal "$url_fragment" "type=abc" # NB no quotes
    local $(ns_url_parse_fragment) ; #local
    assert_equal "$type" "abc" ;   
)

test_ns_url_parse_1
test_ns_url_parse_2
