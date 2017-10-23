#!/bin/bash nspawn.sh

#
# alpine linux image base
#

# configure build
CONFIG log_level=1

# define image identity
IMAGE url="file:///tmp/repo/alp/base/3.6.tar.gz"

# declare dependency images
PULL  url="http://dl-cdn.alpinelinux.org/alpine/v3.6/releases/x86_64/alpine-minirootfs-3.6.2-x86_64.tar.gz#type=plain"

# provision image resources
COPY path=etc:opt

# define container environment
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# set container application
EXEC /opt/entry.sh

# configure packages
#SH apk update
#SH apk upgrade
#SH apk add tzdata
#SH apk add ca-certificates

# publish image to server
PUSH
