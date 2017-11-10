#!/bin/sh

#
# dropbear service unit
#

set -e -u

for kind in rsa dss ecdsa ; do
    echo "ensure key '$kind'"
    path="/etc/dropbear/dropbear_${kind}_host_key"
    [[ -e "$path" ]] || &> /dev/null dropbearkey -t "$kind"  -f "$path"
done

exec $(which dropbear) -F -E -m -s -j -k
