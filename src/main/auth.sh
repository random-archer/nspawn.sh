#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# image server authentication
#

# parse path to list
ns_auth_path() {
    local IFS=':'
    local auth_path=( ${ns_CONF[auth_path]} )
    unset IFS
    declare -p auth_path
}

# discover remote auth config
ns_auth_conf() { 
    local "$@" ; ns_log_req url kind
    
    eval "$(ns_url_parse)"
    
    eval "$(ns_auth_path)"
    
    local auth_conf=()
    
    local entry=; for entry in "${auth_path[@]-}" ; do
        
        # per-host configuration
        local path="${entry}/${url_host}.conf"
        
        # configuration is optional
        [[ -e $path ]] || continue
        
        # inject auth parameters
        local mode= user= pass= token=
        source "$path"
        
        local kind_mode="$kind/$mode"
        case "$kind_mode" in
            http/basic)
                ns_log_dbug "using '$kind_mode' user='$user' pass='*'"
                auth_conf+=(--basic --user "$user:$pass")
                break
                ;;
            http/token)
                ns_log_dbug "using '$kind_mode' token='*'"
                auth_conf+=(--header "Authorization: Token $token")
                break 
                ;;
            *) 
                ns_log_fail "wrong kind/mode='$kind_mode'" 
                ;;
        esac
          
    done
    
    declare -p auth_conf
}
