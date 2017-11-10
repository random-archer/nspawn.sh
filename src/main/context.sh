#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# image/machine settings persistence
#

# ensure variable declaration
ns_context_assert() {
    local name=; for name in $context ; do
        ns_a_has_declare "$name"
    done
}

# persist settings
ns_context_any_save() { 
    local "$@" # file context
    # context declared
    ns_context_assert
    # export into file
    declare -p $context | ns_a_save
}

# restore settings in local context
ns_context_any_load() { 
    local "$@" # file context
    # context declared
    ns_context_assert
    # import from file
    source "$file" ; declare -p $context
}

# persist image settings
ns_context_image_save() { 
    local "$@" # file
    ns_context_any_save context="$image_context"
}

# restore image settings
ns_context_image_load() { 
    local "$@" # file
    ns_context_any_load context="$image_context"
}

# persist container settings
ns_context_machine_save() { 
    local "$@" # file
    ns_context_any_save context="$machine_context"
}

# restore container settings
ns_context_machine_load() { 
    local "$@" # file
    ns_context_any_load context="$machine_context"
}
