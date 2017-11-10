#!/bin/sh

#
# service launcher
#

set -e -u

base=$(cd $(dirname $0) && pwd)

echo "### ip ad"
ip ad

source "$base/service.sh"

run_loop "$base/unit_network.sh" &

run_loop "$base/unit_dropbear.sh" &

#run_loop "$base/unit_sshd.sh" &

stay
