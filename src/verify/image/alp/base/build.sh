#!/bin/bash nspawn.sh

#
# alpine linux image base
#

# configure build mode
CONFIG build_store_reset=yes # log_level=5

# define image identity
IMAGE url="file:///tmp/repo/alp/base/3.6.tar.gz"

# declare dependency images
PULL  url="http://dl-cdn.alpinelinux.org/alpine/v3.6/releases/x86_64/alpine-minirootfs-3.6.2-x86_64.tar.gz#type=plain"

# provision image resources
# form local path relative to build script
COPY path=etc:opt:root

# define container environment variables
ENV BUILD=$(date +"%Y-%m-%d_%H-%M-%S")

# force ash to use profile 
ENV ENV="/etc/profile"

# define configuration file
DEF path="/etc/apk/repositories" << END
http://dl-cdn.alpinelinux.org/alpine/v3.6/main
http://dl-cdn.alpinelinux.org/alpine/v3.6/community
END

# prove container application entry point
EXEC "/opt/entry.sh"

# configure packages
SH apk update
SH apk upgrade
SH apk add tzdata
SH apk add ca-certificates
SH apk add busybox-initscripts
SH apk add mc htop

# publish image to server
PUSH
