#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

#
# application logger
#

# redirect logging to stderr
ns_log_any() {
    local date=$(ns_a_date_time)
    1>&2 echo "$date $@"
    #    local nest=${BASH_SUBSHELL}
    #    local call=${#FUNCNAME[@]}
    #    1>&2 printf '%s  %d %02d  %s\n' "$date" "$nest" "$call" "$@"
}

# render logger level
ns_log_cat() {
    local "$@"
    case "$level" in
        0) echo "FAIL" ;;
        1) echo "WARN" ;;
        2) echo "INFO" ;;
        3) echo "DBUG" ;;
        4) echo "NOTE" ;;
        *) false ;; # trap
    esac
}

# render logger string
ns_log_run() {
    (( ns_CONF[log_level] >= level )) || return 0 
    local cat=$(ns_log_cat)
    #    local depth=$(ns_a_stack_depth)
    #    local tab=$(ns_a_char_reps char=" " reps=$(ns_a_stack_depth))
    local func=${FUNCNAME[2]} # look back
    ns_log_any "$cat [$func] $@"
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
    local key= value= 
    
    local header="----"
    local report="$header [${FUNCNAME[1]}]"
    
    local entry= ; for entry in "$@" ; do
        [[ "$entry" == *=* ]] && {
            key="${entry%%=*}" 
            value="${entry#*=}"
            report="$report $key='$value'"       
        } || {
            report="$report '$entry'"
        }
    done
    
    ns_log_any "$report"
}

# assert required variables are defined and report at log level
ns_log_req() { 
    
    local func="${FUNCNAME[1]}"
    local line="${BASH_LINENO[1]}"

    local header="****"

    local key= val= report= level=9
            
    for key in "$@" ; do
        [[ $key == "--warn" ]] && level=1 && continue || true
        [[ $key == "--info" ]] && level=2 && continue || true
        [[ $key == "--dbug" ]] && level=3 && continue || true
        [[ $key == "--note" ]] && level=4 && continue || true
        
        [[ $key =~ ^--.* ]] && {
            ns_log_any "$header [$func] invalid option: $key" 
            ns_trap_do_error
        } || true
        
        if ns_a_has_declare "$key" ; then
            val=$(ns_a_read_declare "$key") 
            report="$report $key='$val'"
        else # FIXME stack
            ns_log_any "$header [$func] line=$line require: missing '$key' stack='${FUNCNAME[*]}'"
            ns_trap_do_error
        fi
        
    done
    
    (( ns_CONF[log_level] >= level )) && {
        header=$(ns_log_cat level="$level")
        ns_log_any "$header*[$func] $report"
    } || true
    
}
