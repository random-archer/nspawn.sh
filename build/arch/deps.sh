#!/bin/bash

#
# install build dependencies
#

set -e -u

sudo pacman --sync --needed --noconfirm \
    git \
    inotify-tools \
