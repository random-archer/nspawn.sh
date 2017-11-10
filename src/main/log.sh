#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# application logger
#

# sanitize '--user user:pass'
ns_log_filter() {
    false # TODO
}

# detect color environment
ns_log_has_color_vars() {
    local entry=; for entry in ${ns_CONF[log_color_vars]-} ; do
        ns_a_has_declare "$entry" && return 0 # variable present
    done
    return 1
}

# detect color environment
ns_log_has_no_color_vars() {
    local entry=; for entry in ${ns_CONF[log_no_color_vars]-} ; do
        ns_a_has_declare "$entry" && return 0 # variable present
    done
    return 1
}

# detect color capabilities
ns_log_has_color_caps() {
    ns_a_has_declare "TERM" && # terminal defined
    [[ $TERM != "dumb" ]] && # ignore dumb terminal
    &>/dev/null type -p tput && # terminfo present
    [[ $(tput colors) -ge 8 ]] && # has some colors
    true
}    

# can logger use color
ns_log_has_color() {
    ns_log_has_no_color_vars && return 1
    ns_log_has_color_vars || ns_log_has_color_caps
}

# redirect logging to stderr
ns_log_any() {
    local date=$(ns_a_date_time)
    local line="$date $@"; # line=${line:0:${ns_CONF[log_truncate]}}
    1>&2 echo -e "$line" # note '-e'
    
    #    local nest=${BASH_SUBSHELL}
    #    local call=${#FUNCNAME[@]}
    #    1>&2 printf '%s  %d %02d  %s\n' "$date" "$nest" "$call" "$@"
}

# should use color
ns_log_use_color() {
    [[ ${ns_CONF[log_color]} == yes ]] ||
    [[ ${ns_CONF[log_color]} == auto && ${ns_LOG[has_color]} == yes ]]
}

# set default colors
ns_log_color_set() {
    ns_log_use_color || return 0
    1>&2 echo -e -n "${ns_LOG[color_none]}${ns_LOG[color_back_set]}" 
}

# restore default colors
ns_log_color_unset() {
    ns_log_use_color || return 0
    1>&2 echo -e -n "${ns_LOG[color_none]}${ns_LOG[color_back_unset]}" 
}

# render logger string
ns_log_run() {
    
    local rx="args|trap" 

    # FIXME
    [[ $level =~ $rx ]] || (( ns_CONF[log_level] >= level )) || return 0
     
    local text=${ns_LOG[$level/text]}
    
    local color_head= 
    local color_tail=
    if ns_log_use_color ; then
        color_head=${ns_LOG[$level/color]} # ${ns_LOG[color_back_set]}
        color_tail=${ns_LOG[color_fill]}${ns_LOG[color_none]}
    fi
        
    #    local depth=$(ns_a_stack_depth)
    #    local tab=$(ns_a_char_reps char=" " reps=$(ns_a_stack_depth))
    
    local func=${FUNCNAME[2]} # look back
    ns_log_any "$color_head" "$text" "[$func]" "$@" "$color_tail"
}

ns_log_fail()  {
     local level=0
     ns_log_run "$@"
     ns_trap_do_error # XXX
}

ns_log_warn()  { 
     local level=1
     ns_log_run "$@" 
}

ns_log_info()  { 
     local level=2
     ns_log_run "$@" 
}

ns_log_dbug() { 
     local level=3
     ns_log_run "$@" 
}

ns_log_note() { 
     local level=4
     ns_log_run "$@" 
}

# pretty print arguments, all levels
ns_log_args() { 
    local key= val= report=
    local entry=; for entry in "$@" ; do
        [[ "$entry" == *=* ]] && {
            key="${entry%%=*}" 
            val="${entry#*=}"
            report="$report $key='$val'"       
        } || {
            report="$report '$entry'"
        }
    done
    
    local level="args"
    ns_log_run "$report" 
}

# assert required variables are defined and report at log level
ns_log_req() { 
    # "$@" expects list of names and options    
    local key= val= report= level=9
    for key in "$@" ; do
        [[ $key == "--warn" ]] && level=1 && continue || true
        [[ $key == "--info" ]] && level=2 && continue || true
        [[ $key == "--dbug" ]] && level=3 && continue || true
        [[ $key == "--note" ]] && level=4 && continue || true
        
        [[ $key =~ ^--.* ]] && {
            ns_log_trap type="invalid option: $key" 
            ns_trap_do_error # does not return
        } || true
        
        if ns_a_has_declare "$key" ; then
            val=$(ns_a_read_declare "$key") 
            report="$report $key='$val'"
        else
            ns_log_trap type="require variable: '$key'"
            ns_trap_do_error # does not return
        fi
    done
    
    (( ns_CONF[log_level] >= level )) && {
        ns_log_run "$report"
    } || true
}

# report error trace
ns_log_trap() {
    local "$@" # type
    local nest="$BASH_SUBSHELL"
    local func="${FUNCNAME[2]}"
    local line="${BASH_LINENO[1]}"
    local file="${BASH_SOURCE[2]##*/}" 
    local stack="${FUNCNAME[*]}"; stack=${stack// / <- }
    local place="$file:$line"
    
    local level="trap"
    ns_log_run "type='$type' nest=$nest func='$func' place='$place' stack='$stack'"
}
