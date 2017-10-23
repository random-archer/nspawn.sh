#!/bin/bash

set -e -u

source "${BASH_SOURCE%/*}/a.sh"

nspawn.sh run=unit/upgrade name="$name" url="$url"
