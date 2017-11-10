#!/bin/bash nspawn.sh

#
# alpine linux image with network
#

# configure build mode
CONFIG build_store_reset=yes # log_level=5

# define image identity
IMAGE url="file:///tmp/repo/alp/serv/3.6.tar.gz"

# declare dependency images
PULL  url="file:///tmp/repo/alp/base/3.6.tar.gz"

# provision image resources
COPY path=etc:opt:var:root

# configure container network
PROF MACVLAN=wire0

# define container environment
ENV MACHINE_NAME=alp-serv MACHINE_FACE=mv-wire0

# start full system
INIT

# configure packages
#SH apk add openssh
SH apk add dropbear
SH apk add sudo

# configure network    
DEF path="/etc/network/interfaces" << END
auto lo
iface lo inet loopback
auto $MACHINE_FACE
iface $MACHINE_FACE inet dhcp
END
    
# provide host name
SH "echo '$MACHINE_NAME' > /etc/hostname"
    
# disable tty
SH "sed -i -r -e 's/^(tty[0-9]:.*)/#\1$/' /etc/inittab"

# provide console
SH "echo 'console::respawn:/sbin/getty 38400 console' >> /etc/inittab"

# configure services 
for unit in hostname bootmisc syslog; do
   SH rc-update add $unit boot
done
for unit in dropbear; do
   SH rc-update add $unit default
done
for unit in killprocs savecache; do
   SH rc-update add $unit shutdown
done

# publish image to server
PUSH
