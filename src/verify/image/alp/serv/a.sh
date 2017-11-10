#!/bin/bash

#
# container identity
#

name="alp-serv"
url="file:///tmp/repo/alp/serv/3.6.tar.gz"

nspawn_params="Environment=XYZ=4-5-6"

args=(
    name="$name" 
    url="$url"
    log_level=5
    nspawn_params="$nspawn_params"
)

eval "$@" # mode

nspawn.sh run=unit/$mode "${args[@]}" 
