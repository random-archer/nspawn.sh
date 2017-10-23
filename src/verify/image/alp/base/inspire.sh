#!/bin/bash

#
# create container
#

set -e -u

source "${BASH_SOURCE%/*}/a.sh"

nspawn.sh run=unit/inspire name="$name" url="$url" \
    nspawn_params="$nspawn_params" \
    log_level=5
