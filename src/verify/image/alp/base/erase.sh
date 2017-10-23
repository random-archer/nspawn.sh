#!/bin/bash

#
# delete container
#

set -e -u

source "${BASH_SOURCE%/*}/a.sh"

nspawn.sh run=unit/erase name="$name" url="$url"
