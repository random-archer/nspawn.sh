#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

source "${BASH_SOURCE%/*}/a.sh"

test_ns_main_bash_assert() (
    ns_log_args
    ns_main_bash_assert
)

#declare -p | grep 'ns_'
#declare -F | grep 'ns_'

test_ns_main_bash_assert
