#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

source "${BASH_SOURCE%/*}/a.sh"

test_ns_parse_entry() (
    ns_init_all
    ns_log_args
    local entry="key=val --option" # space
    eval "$(ns_parse_entry)" # key val
    assert_equal "$key" "key"
    assert_equal "$val" "val --option"
)

test_ns_parse_make_quoted_1() (
    ns_init_all
    ns_log_args
    local entry="Environment=XXX=a b c"
    assert_equal "$(ns_parse_make_quoted)" 'Environment="XXX=a b c"'
)

test_ns_parse_make_quoted_2() (
    ns_init_all
    ns_log_args
    declare -a image_entry='([0]="Environment=ECLIPSE_FOLDER=/opt/eclipse" [1]="Environment=ECLIPSE_COMMAND=/opt/eclipse/eclipse" [2]="Environment=ECLIPSE_INSTALL=/opt/eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director")'
    local entry="${image_entry[2]}"
    assert_equal "$(ns_parse_make_quoted)" 'Environment="ECLIPSE_INSTALL=/opt/eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director"'
)

test_ns_parse_enviro() (
    ns_init_all
    ns_log_args
    local entry='Environment="KEY=SOME VALUE"'
    eval "$(ns_parse_enviro)" # key val
    assert_equal "$key" "KEY"
    assert_equal "$val" "SOME VALUE"
)

test_ns_parse_entry
test_ns_parse_make_quoted_1
test_ns_parse_make_quoted_2
test_ns_parse_enviro
