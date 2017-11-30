#!/bin/bash

#
# test container instance setup
#

set -e -u -x

source "${BASH_SOURCE%/*}/a.sh"

docker_pull

docker_inst

docker_exec $pacrun --sync "${package_list[@]}"

sysd_wait_active unit=dbus

docker_logs

sysd_report_status
