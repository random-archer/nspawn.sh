#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# url parser
#

# assemble url from context variables
ns_url_build() { 
    local "$@"
    
    local login= server=
    
    [[ $user ]] && login="$user" || true 
    [[ $user && "$pass" ]] && login="$user:$pass" || true
    [[ $login ]] &&  login="$login@" || true
    [[ $host ]] && server="$host" || true 
    [[ $port ]] && server="$server:$port" || true 
    [[ $query ]] && query="?$query" || true 
    [[ $fragment ]] && fragment="#$fragment" || true
     
    echo "${scheme}://${login}${server}${path}${query}${fragment}"
}

# inject url_* components
ns_url_parse() { 
    local "$@" # scheme://user:pass@host:port/path?query#fragment
    
    # temp vars
    local authority= login= base= 
    
    # return object
    local url_scheme= url_user= url_pass= url_host= url_port= url_path= url_query= url_fragment= 
    
    # scheme
    url_scheme="${url%'://'*}" 
    
    # user:pass@host:port
    authority="${url#*'://'}"
    authority="${authority%%'/'*}" 
    
    [[ $authority == *'@'* ]] && {
        # user:pass
        login="${authority%%'@'*}"
        # user
        url_user="${login%':'*}"  
        # pass
        [[ $login == *':'* ]] && url_pass="${login#*':'}" || true
    } || true
    
    base="${authority##*'@'}" # host:port
    
    # host
    url_host="${base%':'*}" 
    
    # port
    [[ $base == *':'* ]] && {
        url_port="${base#*':'}" 
    } || true
    
    # path
    url_path="${url##$url_scheme'://'$authority}"
    url_path="${url_path%%'#'*}"
    url_path="${url_path%%'?'*}" 

    # query    
    [[ $url == *'?'* ]] && {
        url_query="${url##*'?'}"
        url_query="${url_query%%'#'*}" 
    } || true
     
    # fragment
    [[ $url == *'#'* ]] && {
        url_fragment="${url##*'#'}" 
    } || true

    # defaults     
    [[ $url_scheme == "http" && ! $url_port ]] && url_port="80" || true
    [[ $url_scheme == "https" && ! $url_port ]] && url_port="443" || true
    
    # result
    declare -p ${!url_*}
}

ns_url_parse_query() {
    ns_parse_ampersand "$url_query" 
}

ns_url_parse_fragment() { 
    ns_parse_ampersand "$url_fragment" 
}
