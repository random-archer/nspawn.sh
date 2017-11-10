#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
#
# 

set -o nounset # fail on unset variables
set -o errexit  # fail on non-zero function return
set -o errtrace # apply ERR trap throughout call stack
set -o functrace # apply DEBUG and RETURN trap throughout the stack


#!/bin/bash
# find -E biz -regex '.*\.(pom|jar)$' -exec bintrayup.sh "{}" ";"

BINTRAY_USER=xxx
BINTRAY_API_KEY=yyy
SLUG=bnd/bnd
file=$1
packageprefix=${file%/*/*}
versionprefix=${file%/*}
package=${packageprefix##*/}
version=${versionprefix##*/}

curl \
   -u${BINTRAY_USER}:${BINTRAY_API_KEY} \
   -X POST \
   -H Content-Type:\ application/json 
   -d \{\"name\":\"${version}\"\,\"desc\":\"\"\,\"vcs_tag\":\"${version}.REL\"\} 
   https://api.bintray.com/packages/${SLUG}/${package}/versions

curl \
   -u${BINTRAY_USER}:${BINTRAY_API_KEY} \
   -T ${file} https://api.bintray.com/maven/${SLUG}/${package}/${file}
