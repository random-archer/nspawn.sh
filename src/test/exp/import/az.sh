#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

#
# verify import once
#

set -e -u

source "${BASH_SOURCE%/*}/a1.sh"
source "${BASH_SOURCE%/*}/a1.sh"
source "${BASH_SOURCE%/*}/a1.sh"

source "${BASH_SOURCE%/*}/a2.sh"
source "${BASH_SOURCE%/*}/a2.sh"
source "${BASH_SOURCE%/*}/a2.sh"
