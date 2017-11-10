#!/bin/bash

#
# shell access to live container
#

set -e -u

name="alp-base"

# machine pid
pid=$(machinectl show --property Leader --value "$name")

# container environment
vars=$(sudo cat /proc/$pid/environ | xargs -0)
# invocation environment
vars="$vars TERM=$TERM"
    
# join name space with environment
sudo nsenter --target=$pid --mount --uts --ipc --net --pid env -i - $vars sh
