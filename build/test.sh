#!/bin/bash

#
# release tester
#

set -e -u

# unit test
"${BASH_SOURCE%/*}/../src/test/exec.sh"
