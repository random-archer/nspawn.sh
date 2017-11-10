#!/bin/bash

#
# container identity
#

set -e -u

name="alp-base"
url="file:///tmp/repo/alp/base/3.6.tar.gz"

nspawn_params="Environment=ABC=1-2-3"

args=(
    name="$name" 
    url="$url"
    log_level=5
    nspawn_params="$nspawn_params"
)

eval "$@" # mode

nspawn.sh run=unit/$mode "${args[@]}" 
