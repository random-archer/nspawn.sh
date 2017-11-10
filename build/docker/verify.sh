#!/bin/bash

#
# invoke tests in docker
#

set -e -u -x

source "${BASH_SOURCE%/*}/a.sh"

docker_exec /bin/bash "$proj/build/make.sh"

docker_exec /bin/bash "$proj/src/test/exec.sh"

docker_exec /bin/bash "$proj/src/verify/image/exec.sh"
