#!/bin/bash

#
# squash commits after a point
#

set -e -u

# 2017-10-23 10:29:32
point=383383fb672d096797bde519c3f49f08f7c4bb46

git reset --soft $point

git commit -m "develop"

git push --force
