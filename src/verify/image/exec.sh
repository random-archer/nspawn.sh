#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

#
# verify image build
#

set -o nounset # fail on unset variables
set -o errexit  # fail on any non-zero return
set -o pipefail # fail on any internal pipe error
set -o errtrace # apply ERR trap throughout call stack
set -o functrace # apply DEBUG and RETURN trap throughout the stack 

# use project artifact 
#proj=$(git rev-parse --show-toplevel)
#PATH="$proj:$PATH"
nspawn_sh=$(type -p nspawn.sh)
echo nspawn_sh=$nspawn_sh

#
repo_path="$/tmp/repo"
build_path="#build#"
sudo rm -rf $repo_path 
sudo rm -rf /var/lib/nspawn.sh/archive/{$repo_path,$build_path}
sudo rm -rf /var/lib/nspawn.sh/extract/{$repo_path,$build_path}

#
path_list=(
    "alp/base"
    "alp/serv"
)

#
base=${BASH_SOURCE%/*}

#
path=; for path in "${path_list[@]}" ; do
    echo "------------------------------------"
    "$BASH" "$nspawn_sh" "$base/$path/build.sh"
done
