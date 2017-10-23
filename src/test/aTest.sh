#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

source "${BASH_SOURCE%/*}/a.sh"

test_ns_a_text_hash() (
    ns_init_all
    ns_log_args
    local source=$(ns_a_text_hash text="hello-kitty")
    local target="926b49a45a72941f8f3ab1ab72615aee"
    assert_equal "$source" "$target"
)

test_ns_a_guid_char() (
    ns_init_all
    ns_log_args
    echo $(ns_a_guid_char) > /dev/null
)

test_ns_a_path_dir() (
    ns_init_all
    ns_log_args
    local path=$(mktemp -d -u)
    local dir=$(ns_a_path_dir)
    assert_equal "/tmp" "$dir"
)

test_ns_a_path_file() (
    ns_init_all
    ns_log_args
    local path=$(mktemp -u)
    local file=$(ns_a_path_file)
    assert_equal "${path#/tmp/}" "$file"
)

test_ns_a_has_declare() (
    ns_init_all
    ns_log_args
    ! ns_a_has_declare map
    declare -A map=([one]=1 [two]=2)
    ns_a_has_declare map
)

test_ns_a_read_declare() (
    ns_init_all
    ns_log_args
    declare -A map=([one]=1)
    ns_a_has_declare map
    local val=$(ns_a_read_declare map)
    assert_equal '([one]="1" )' "$val"
)

test_ns_a_char_reps() (
    ns_init_all
    ns_log_args
    local line=$(ns_a_char_reps char="-" reps="5")
    assert_equal "-----" "$line"
)

test_ns_a_text_hash
test_ns_a_guid_char
test_ns_a_path_dir
test_ns_a_path_file
test_ns_a_has_declare
test_ns_a_read_declare
test_ns_a_char_reps
