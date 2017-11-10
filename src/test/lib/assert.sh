#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# test support
#

# compare text to text
assert_equal() { 
    [[ "$1" == "$2" ]] && return 0
    1>&2 echo "${BASH_SOURCE[2]} ${FUNCNAME[1]}: not equal: [$1] vs [$2]"
    return 1 
}

# compare file to text
assert_equal_file() { 
    assert_equal "$(cat "$1")" "$2"
}

# variable is defined
assert_def() {
    [[ $1 ]] && return 0
    1>&2 echo "${BASH_SOURCE[2]} ${FUNCNAME[1]}: not defined: [$1] vs [$2]"
    return 1 
}

# variable is defined and non empty
assert_val() {
    [[ ${1-} ]] && return 0
    1>&2 echo "${BASH_SOURCE[2]} ${FUNCNAME[1]}: not defined: [$1] vs [$2]"
    return 1 
}

assert_match() { 
    [[ "$1" =~ "$2" ]] && return 0
    1>&2 echo "${BASH_SOURCE[2]} ${FUNCNAME[1]}: not match: [$1] vs [$2]"
    return 1 
}
