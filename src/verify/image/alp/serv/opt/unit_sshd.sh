#!/bin/sh

#
# sshd service unit
#

set -e

ssh-keygen -A

exec $(which sshd) -D
