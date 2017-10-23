#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

#
# image server proxy access
#

# verify if proxy host:port is open
ns_proxy_test() { 
    local "$@"
    eval "$(ns_url_parse)"
    netcat -w 1 -z "$url_host" "$url_port" || return 0  # TODO config timeout
    echo "$url"
}

# generate proxy env-var entries
ns_proxy_env_text() { 
    local prefix="Environment="
    local http="${ns_STATE[proxy_http]}"
    local https="${ns_STATE[proxy_https]}"
    
    [[ $http ]] && echo "${prefix}http_proxy=$http" "${prefix}HTTP_PROXY=$http" || true 
    [[ $https ]] && echo "${prefix}https_proxy=$https" "${prefix}HTTPS_PROXY=$https"  || true
}

# provide proxy environment for image pull
ns_proxy_create() { 
    [[ ${ns_STATE[proxy]} == yes ]] && return 0  || ns_STATE[proxy]=yes # discover proxy once
    
    local http= https= mode="${ns_CONF[proxy_mode]}"
    ns_log_info "mode '$mode'"
    
    case "$mode" in
        
    none) return 0 ;;
    
    auto) # try env-var, then config
        http="${http_proxy:-${HTTP_PROXY:-${ns_CONF[proxy_http]}}}"             
        https="${https_proxy:-${HTTPS_PROXY:-${ns_CONF[proxy_https]}}}"             
        ;;
        
    config) # use config only
        http="${ns_CONF[proxy_http]}"
        https="${ns_CONF[proxy_https]}"
        ;;
        
    inherit) # use env-var only
        http="${http_proxy:-${HTTP_PROXY:-}}"             
        https="${https_proxy:-${HTTPS_PROXY:-}}"
        ;;
                     
    *) ns_log_fail "wrong mode '$mode'" ;;
    
    esac
        
    http=$(ns_proxy_test url=$http)
    https=$(ns_proxy_test url=$https)
    
    ns_STATE[proxy_http]="$http"
    ns_STATE[proxy_https]="$https"
    
    [[ $http ]] && export http_proxy="$http" HTTP_PROXY="$http" || ns_log_warn "missing http proxy"  
    [[ $https ]] && export https_proxy="$https" HTTPS_PROXY="$https" || ns_log_warn "missing https proxy" 
}

# remove proxy environment
ns_proxy_delete() {
    [[ ${ns_STATE[proxy]} == yes ]] || return 0 ; ns_STATE[proxy]=no
    
    export http_proxy= HTTP_PROXY=
    export https_proxy= HTTPS_PROXY=
}
