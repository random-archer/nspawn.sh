#!/bin/sh

set -e

nspawn_date() { date +"%Y-%m-%d_%H-%M-%S" ; } # ISO date/time stamp
nspawn_note() { 1>&2 echo "service.sh: $@" ; } # redirect logging

run_loop() { # ensure continuous run
    nspawn_note "init: $@"
    until "$@" ; do
        nspawn_note "exit '$?': $@"
        sleep 1
    done
    nspawn_note "done: $@"    
}

run_once() { # ensure single invocation
    nspawn_note "init: $@"
    "$@" || nspawn_note "exit '$?': $@"
    nspawn_note "done: $@"    
}

run_term() { # run once and terminate all
    run_once "$@"
    kill -TERM $$ # notify parent
    sleep 1 # let parent process signal
}

term() { # terminate services
    nspawn_note "term: kill"
    kill -TERM $(jobs -p)
    nspawn_note "term: wait"
    wait # wait for jobs
    nspawn_note "term: exit"
    exit 0 # session finished
}

stay() { # await termination
    sleep 1 # let jobs run first
    nspawn_note "stay: wait"
    wait # wait for trap
    nspawn_note "stay: exit"
    return 0 # session finished
}

trap term TERM
