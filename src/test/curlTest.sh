#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

source "${BASH_SOURCE%/*}/a.sh"

test_ns_curl_parse_last_modified() (
    ns_init_all
    ns_log_args
    local content=$(cat "${BASH_SOURCE%/*}/res/curl.head.txt")
    local header=$(ns_curl_parse_last_modified)
    echo "header='$header'"
    assert_equal "$header" "Sun, 01 Jan 2012 17:23:29 GMT"
)

test_curl_live_header() (
    ns_init_all
    ns_log_args
    local url="http://www.carrotgarden.com"
    local curl_cmd="curl --silent --fail --show-error"
    local head_text=$($curl_cmd --head "$url")
    local time_stamp=$(ns_curl_parse_last_modified content="$head_text")
    echo "time_stamp='$time_stamp'"
)


test_ns_curl_parse_last_modified

test_curl_live_header
