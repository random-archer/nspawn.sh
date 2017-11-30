#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

source "${BASH_SOURCE%/*}/a.sh"

test_ns_auth_path() (
    ns_init_all
    ns_log_args
    eval "$(ns_auth_path)"
    assert_equal "${auth_path[0]}" "/etc/nspawn.sh/auth"
    assert_equal "${auth_path[1]}" "$HOME/.nspawn.sh/auth"
)

test_ns_auth_path
