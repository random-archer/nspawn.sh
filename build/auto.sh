#!/bin/bash

#
# automatic build system
#

# use 'auto_*' name space

readonly auto_base=${BASH_SOURCE%/*}
readonly auto_proj=$(cd "$auto_base/.." && pwd)
readonly auto_inst="$auto_proj/src/inst"
readonly auto_main="$auto_proj/src/main"
readonly auto_test="$auto_proj/src/test"

# fail fast
auto_setup_shell() {
    set -o nounset # fail on unset variables
    set -o errexit  # fail on non-zero function return
    set -o errtrace # apply ERR trap throughout call stack 
    set -o functrace # apply DEBUG and RETURN trap throughout the stack 
}

# build on demand
auto_invoke_build() {
    auto_setup_shell
    echo "$(date +%Y-%m-%d_%H-%M-%S) path='$path' file='$file' event='$event'"
    [[ $file =~ .sh ]] || return 0
    # ensure permission
    chmod +x "$path/$file"
    # discover test unit
    local unit=;
    [[ $file =~ Test.sh ]] && unit="$file" || unit="${file%.sh}Test.sh"
    # invoke test
    local exec="$auto_test/$unit"
    [[ -f $exec ]] && $exec
    # make package
    "$auto_base/make.sh"
}

# remove monitor
auto_monitor_stop() {
    killall inotifywait || true
}
 
# setup interrupts   
auto_trap_init() {
    trap auto_trap_on_exit EXIT
}

# project cleanup
auto_trap_on_exit() {
    auto_monitor_stop
}

# change detector
auto_monitor_run() {
    auto_setup_shell
    inotifywait \
        --recursive \
        --event modify \
        --monitor "$auto_inst" \
        --monitor "$auto_main" \
        --monitor "$auto_test" \
        --monitor "$auto_base" |
        while read path event file ; do
            auto_invoke_build || true
        done
}

# automatic build cycle
auto_trap_init
auto_monitor_stop
auto_monitor_run
