#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

#
# container overlay file system
#

# empty overlay bottom folder needed during image build
ns_overlay_zoom() { 
    [[ ${ns_STATE[main]} == "build" ]] && echo "${machine[zoom_dir]}" || true
}

# map from url list to extract root path
ns_overlay_extract() { 
    local overlay=($(ns_overlay_zoom)) # no quotes
    
    local url=; for url in "${machine_overlay[@]-}" ; do
        
        # local context
        eval "$(ns_store_space)"
        
        [[ -d $store_extract ]] || ns_log_fail "missing $store_extract"
        
        # order: top > ... > bottom
        overlay=("$store_root" ${overlay[@]+"${overlay[@]}"}) 
    done
    
    # return overlay path line with path separator
    local IFS=':' ; echo "${overlay[*]}" ; unset IFS 
}

# generate mount options
ns_overlay_options() { 
    local lower=$(ns_overlay_extract)
    local upper="${machine[root_dir]}"
    local work="${machine[work_dir]}"
    echo "upperdir=$upper,lowerdir=$lower,workdir=$work"
 }

# check if container mount is active
ns_overlay_has_mount() { 
    local point="${machine[machine_dir]}"
    # point must be inside spaces
    ns_a_sudo mount | grep -q -E "(\s+)$point(\s+)"
}

# generate 'mount' command 
ns_overlay_create_cmd() {
    local "$@" ; ns_log_req point
    local options="$(ns_overlay_options)"
    echo $(type -p mount) -t 'overlay' -o "$options" "overlay" "$point" 
}

# generate 'umount' command 
ns_overlay_delete_cmd() {
    local "$@" ; ns_log_req point
    echo $(type -p umount) -t 'overlay' "$point" 
}

# mount container overlay
ns_overlay_create() { 
    # machine
    local point="${machine[machine_dir]}" 
    ns_log_dbug "point '$point'"
    ns_overlay_has_mount && { ns_log_dbug "overlay is present" ; return 0 ; }
    ns_a_sudo $(ns_overlay_create_cmd)
}

# umount container overlay
ns_overlay_delete() { 
    # machine
    local point="${machine[machine_dir]}"
    ns_log_dbug "point '$point'"
    ns_overlay_has_mount || { ns_log_dbug "overlay is missing" ; return 0 ; }
    ns_a_sudo $(ns_overlay_delete_cmd)
}
