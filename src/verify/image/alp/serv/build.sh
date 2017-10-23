#!/bin/bash nspawn.sh

#
# alpine linux image with network
#

# configure build
CONFIG log_level=1

# define image identity
IMAGE url="file:///tmp/repo/alp/serv/3.6.tar.gz"

# declare dependency images
PULL  url="file:///tmp/repo/alp/base/3.6.tar.gz"

# provision image resources
COPY path=etc:opt:var:root

# define container environment
ENV MACHINE_NAME=alp-serv MACHINE_FACE=mv-wire0

#
SET MACVLAN=wire0

# set container entry
EXEC /opt/entry.sh

# configure packages
SH apk add openssh
SH apk add dropbear
SH apk add mc htop sudo

# publish image to server
PUSH
