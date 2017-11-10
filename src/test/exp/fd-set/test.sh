#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# bash minimal fd set: 0, 1, 2, 255
# fd=3 is eclipse console in this test
# 

set -o nounset # fail on unset variables
set -o errexit  # fail on non-zero function return
set -o errtrace # apply ERR trap throughout call stack
set -o functrace # apply DEBUG and RETURN trap throughout the stack

list_fd() {
    for fd in $(ls /proc/$$/fd); do
      #eval "exec $fd>&-"
      echo "fd=$fd"
    done
}

list_fd
