#!/bin/sh

#
# service manager
#

set -e -u

a_date() { date +"%Y-%m-%d_%H-%M-%S" ; } # ISO date/time stamp
a_note() { 1>&2 echo "service.sh: $@" ; } # redirect logging

run_loop() { # ensure continuous run
    a_note "init: $@"
    until "$@" ; do
        a_note "exit '$?': $@"
        sleep 1
    done
    a_note "done: $@"    
}

run_once() { # ensure single invocation
    a_note "init: $@"
    "$@" || a_note "exit '$?': $@"
    a_note "done: $@"    
}

run_term() { # run once and terminate all
    run_once "$@"
    kill -TERM $$ # notify parent
    sleep 1 # let parent process signal
}

term() { # terminate services
    a_note "term: kill"
    kill -TERM $(jobs -p)
    a_note "term: wait"
    wait # wait for jobs
    a_note "term: exit"
    exit 0 # session finished
}

stay() { # await termination
    sleep 1 # let jobs run first
    a_note "stay: wait"
    wait # wait for trap
    a_note "stay: exit"
    return 0 # session finished
}

trap term TERM
