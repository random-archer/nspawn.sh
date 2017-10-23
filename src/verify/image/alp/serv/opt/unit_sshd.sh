#!/bin/sh

set -e

ssh-keygen -A

exec $(which sshd) -D
