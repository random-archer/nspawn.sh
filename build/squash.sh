#!/bin/bash

#
# squash commits after a point
#

set -e -u

# 2017-11-10
point=ef46572d76af7f31b89100f07fdeb963dd24fbc4

git reset --soft $point

git add -A

git commit -m "develop"

git push --force
