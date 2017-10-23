#!/bin/sh

set -e -u

[[ "$MACHINE_NAME" ]] || MACHINE_NAME="alp-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)" 
[[ "$MACHINE_FACE" ]] || MACHINE_FACE="mv-wire0"

ip link set up "$MACHINE_FACE"

exec $(which udhcpc) \
    --fqdn "$MACHINE_NAME" \
    --interface "$MACHINE_FACE" \
    --retries 0 \
    --timeout 1 \
    --tryagain 1 \
    --release \
    --foreground \
