#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

# common curl options
ns_curl_opts() { 
    
    # resolve f.q.d.n. host name
    local text="$(host -4 -W 3 $url_host)"
    local list=($text)
    local host=${list[0]}
    
    local opts_host="--header Host:$host"
    local opts_conf="${ns_CONF[curl_opts]}"
    local opts_auth="$(ns_auth_conf form=curl)" 
    
    echo "$opts_host $opts_conf $opts_auth $opts_more"
}

# curl options for pull
ns_curl_opts_get() {
    local opts_more=""
    [[ ${ns_CONF[proxy_on_get]} == yes ]] || opts_more="--noproxy $url_host"
    ns_curl_opts
}   

# curl options for push
ns_curl_opts_put() {
    local opts_more=""
    [[ ${ns_CONF[proxy_on_put]} == yes ]] || opts_more="--noproxy $url_host"
    ns_curl_opts
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
    echo "$(ns_curl_parse_header)"    
}
