#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# common transport
#

# resolve f.q.d.n. host name
ns_curl_host() {
    local wait=${ns_CONF[curl_host_wait]}
    local text="$(host -4 -W $wait $url_host)"
    local list=($text)
    local host=${list[0]}
    echo "$host"
}

# common curl options
ns_curl_opts_any() { 
    # url_host
    
    local host=$(ns_curl_host)
    
    eval "$(ns_auth_conf kind=http)"
    
    local opts_conf=(${ns_CONF[curl_opts]})
    local opts_host=(--header "Host:$host")
    local opts_prox=(--noproxy ${ns_CONF[proxy_not]})
    
    local curl_list=(
        --disable # keep first
        "${opts_more[@]-}"
        "${opts_host[@]-}"
        "${opts_conf[@]-}"
        "${opts_prox[@]-}"
        "${auth_conf[@]-}"
    )
    
    local curl_opts=()
    local item=; for item in "${curl_list[@]}" ; do
        [[ $item ]] && curl_opts+=("$item") # skip empty
    done 

    declare -p curl_opts                
}

# curl options for pull
ns_curl_opts_get() {
    # url_host
    local opts_more=()
    [[ ${ns_CONF[proxy_on_get]} == yes ]] || opts_more+=(--noproxy "$url_host")
    ns_curl_opts_any
}   

# curl options for push
ns_curl_opts_put() {
    # url_host
    local opts_more=()
    [[ ${ns_CONF[proxy_on_put]} == yes ]] || opts_more+=(--noproxy "$url_host")
    ns_curl_opts_any
}

# parse single http header form response content
ns_curl_parse_header() {
    local "$@" # header content
    shopt -s nocasematch # for sub shell
    local IFS=$'\n'
    local line; for line in $content ; do
        [[ $line =~ $header ]] || continue
        line=${line#*:} # cut to ':'
        line=$(ns_a_trim line="$line") # no spaces
        echo -n "$line" # return
        return 0 # on match
    done
}

  
# extract header 'Last-Modified'
ns_curl_parse_last_modified() {
    local "$@" # content
    local header="last-modified"
    echo "$(ns_curl_parse_header)" # use sub shell
}
