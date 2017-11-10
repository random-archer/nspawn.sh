#!/bin/bash

#
# make self extract program
#

set -e -u

echo "${BASH_SOURCE}"

build_name="nspawn.sh"
build_stamp=$(date +"%Y-%m-%d_%H-%M-%S")

base="${BASH_SOURCE%/*}"
proj=$(cd "$base/.." && pwd)

inst="$proj/src/inst/inst.sh"
inst_subs="$proj/target/inst.sh"

source="$proj/src/main"
target="$proj/target"
archive="$target/main.tar.gz"
program="$proj/$build_name"
install="/usr/local/bin/$build_name"

mkdir -p "$target"

sed -z \
    -e "s/{build_name}/$build_name/g" \
    -e "s/{build_stamp}/$build_stamp/g" \
    "$inst" > "$inst_subs"

tar -c -z -f "$archive" -C "$source" "."

cat "$inst_subs" "$archive" > "$program"

chmod +x "$program"

sudo rsync -a "$program" "$install"
    
ls -ls "$install"
