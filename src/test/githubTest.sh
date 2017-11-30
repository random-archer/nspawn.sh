#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

source "${BASH_SOURCE%/*}/a.sh"

test_ns_github_map_url() (
    ns_init_all
    ns_log_args
    local url="github://random-archer/nspawn.repo/base/arch/2017-11-20.tar.gz"
    eval "$(ns_github_map_url)"
    assert_equal "$github_owner" "random-archer"
    assert_equal "$github_repo" "nspawn.repo"
    assert_equal "$github_item" "base~arch~2017-11-20.tar.gz"
)

test_ns_github_url_get() (
    ns_init_all
    ns_log_args
    local url="github://random-archer/nspawn.repo/base/arch/2017-11-20.tar.gz"
    local url_get=$(ns_github_url_get)    
    assert_equal "$url_get" "https://github.com/random-archer/nspawn.repo/archive/base~arch~2017-11-20.tar.gz"
)

test_ns_github_url_put() (
    ns_init_all
    ns_log_args
    local url="github://random-archer/nspawn.repo/base/arch/2017-11-20.tar.gz"
    local url_put=$(ns_github_url_put)    
    assert_equal "$url_put" "https://uploads.github.com/repos/random-archer/nspawn.repo/releases/base~arch~2017-11-20.tar.gz/assets?name=base~arch~2017-11-20.tar.gz"
)

test_ns_github_do_put() (
    ns_github_do_put
)

test_ns_github_map_url
test_ns_github_url_get
test_ns_github_url_put

#test_ns_github_do_put
