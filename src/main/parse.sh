#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

#
# parser utilities
#

# split key=value entry
ns_parse_entry() { 
    local "$@" 
    local key="${entry%%=*}" value="${entry#*=}" 
    declare -p key value
}

# make quoted key="value" entry
ns_parse_make_quoted() { 
    local "$@" # entry 
    local key="${entry%%=*}" 
    local value="${entry#*=}" 
    printf '%s="%s"' "$key" "$value"
}

# detect single quotes
ns_parse_has_quote_single() { 
    local rx="^'.*'\$" 
    [[ $1 =~ $rx ]] 
} 

# detect double quotes
ns_parse_has_quote_double() { 
    local rx="^".*"\$" 
    [[ $1 =~ $rx ]] 
} 

# remove single quotes
ns_parse_rem_quote_single() { 
    local text="$1" 
    text="${text#\'}" 
    text="${text%\'}" 
    echo -n "$text" 
} 

# remove double quotes
ns_parse_rem_quote_double() { 
    local text="$1" 
    text="${text#\"}" 
    text="${text%\"}" 
    echo -n "$text" 
} 

# parse url parameters: k1=v1&k2=v2&...
ns_parse_ampersand() { 
    local __=__ 
    [[ "${1:-}" ]] && { 
        ns_parse_has_quote_single "$1" && __=$(ns_parse_rem_quote_single $1) || __="$1" 
        local ${__//'&'/' '}
    } 
    local
}

ns_parse_declare() {
    local "$@" # entry
    local key= val=
    key=${entry#declare -- }
    key=${key%%=*}
    val=${entry#*=}
    val=$(ns_parse_rem_quote_double "$val")
    declare -p key val
}

# extract environment variable from entry:
# Environment="KEY=SOME VALUE"
ns_parse_enviro() {
    local "$@" # entry
    eval "$(ns_parse_entry)" # remove prefix
    if ns_parse_has_quote_double "$value" ; then
        entry=$(ns_parse_rem_quote_double "$value") # remove quotes
    elif ns_parse_has_quote_single "$value" ; then
        entry=$(ns_parse_rem_quote_single "$value") # remove quotes
    fi
    eval "$(ns_parse_entry)" # extract variable
    declare -p key value
}
