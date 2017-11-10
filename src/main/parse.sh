#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# parser utilities
#

# split key=val entry
ns_parse_entry() { 
    local "$@" # entry
    local key="${entry%%=*}" val="${entry#*=}" 
    declare -p key val
}


# convert form list key=val into map[key]=val
ns_parse_to_map() {
    local "$@" # key=val ...
    declare -A map=() 
    local entry=; for entry in "$@" ; do
        eval "$(ns_parse_entry)"
        map[$key]="$val"
    done
    declare -p map    
}

# find key=val entry with key
ns_parse_find() {
    local "$@" # key array
    local -n list="$array" # de-reference
    local entry=; for entry in "${list[@]}" ; do
        [[ $entry == "$key="* ]] && echo "$entry"
    done 
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

# remove single or double quotes
ns_parse_rem_quote_any() {
    local text="$1" 
    if ns_parse_has_quote_double "$text" ; then
        ns_parse_rem_quote_double "$text"
    elif ns_parse_has_quote_single "$text" ; then
        ns_parse_rem_quote_single "$text"
    else
        echo -n "$text" 
    fi
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

# extract scalar 'declare -- a="b"'
ns_parse_declare() {
    local "$@" # entry
    local key= val=
    key=${entry#declare -- }
    key=${key%%=*}
    val=${entry#*=}
    val=$(ns_parse_rem_quote_any "$val")
    declare -p key val
}

# extract environment variable from entry:
# Environment="KEY=SOME VALUE"
ns_parse_enviro() {
    local "$@" # entry
    # remove prefix
    eval "$(ns_parse_entry)" # key val
    # remove quotes
    entry=$(ns_parse_rem_quote_any "$val")
    # extract variable
    eval "$(ns_parse_entry)" # key val 
    declare -p key val
}
