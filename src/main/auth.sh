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

# discover remote auth config
ns_auth_conf() { 
    local "$@" ; ns_log_req url form
    
    eval "$(ns_url_parse)"
    
    # configuration locations
    local auth_path=${ns_CONF[auth_path]//':'/' '}
    
    local entry=; for entry in $auth_path ; do
        
        # per-host configuration
        local path="$entry/${url_host}.conf"
        
        # configuration is optional
        [[ -e $path ]] || continue
        
        # inject parameters
        eval "$(source "$path" && declare -p mode user pass)"
        
        local mode_form="$mode/$form"
        case "$mode_form" in
            basic/curl)
                ns_log_dbug "using '$mode_form' user='$user' pass='*'"
                echo "--user $user:$pass" 
                return 0 # on match 
                ;;
            *) 
                ns_log_fail "wrong mode/form='$mode_form'" 
                ;;
        esac
          
    done
}
