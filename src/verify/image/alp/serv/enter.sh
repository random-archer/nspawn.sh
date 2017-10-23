#!/bin/bash

#
# shell access to live container
#

set -e -u

source "${BASH_SOURCE%/*}/a.sh"

machine_pid=$(machinectl show --property Leader "$name" | sed "s/^Leader=//")

sudo nsenter --target="$machine_pid" --mount --uts --ipc --net --pid /bin/sh
