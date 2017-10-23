#!/bin/bash

set -e -u

source "${BASH_SOURCE%/*}/a.sh"

nspawn.sh run=unit/erase name="$name" url="$url" log_level=2
