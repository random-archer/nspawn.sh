#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

source "${BASH_SOURCE%/*}/a.sh"

test_trap_err_direct() { # no sub shell
    ns_init_all
    ns_trap_init
    ns_log_args
    ns_CONF[log_level]=5
    ns_CONF[dbug_trap_skip_exit]=yes
    fun0() {
        >&2 echo "$FUNCNAME $BASH_SUBSHELL $$ $BASHPID"
        echo "here"
        false # error
    }
    fun0
}

test_trap_err_nested() { # no sub shell
    ns_init_all
    ns_trap_init
    ns_log_args
    ns_CONF[log_level]=5
    ns_CONF[dbug_trap_skip_exit]=yes
    fun2() { # sub shell
        >&2 echo "$FUNCNAME $BASH_SUBSHELL $$ $BASHPID"
        echo "here"
        false # error
    }
    fun1() { # sub shell
        >&2 echo "$FUNCNAME $BASH_SUBSHELL $$ $BASHPID"
        echo "$(fun2)"
    }
    fun0(){ # main shell
        >&2 echo "$FUNCNAME $BASH_SUBSHELL $$ $BASHPID"
        echo "$(fun1)"
    }
    fun0
}

test_trap_exit() { # no sub shell
    ns_init_all
    ns_trap_init
    ns_log_args
    ns_CONF[log_level]=5
    ns_CONF[dbug_trap_skip_exit]=yes
    exit
}

#test_trap_err_direct || true

test_trap_err_nested

test_trap_exit # keep last
