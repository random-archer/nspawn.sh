#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

#
# image store management
#

# derive media_* descriptor form image type
ns_store_media() { 
    local "$@" # url
    
    local $(ns_url_parse_fragment) # type root meta
    
    local media_type= ; # known image type
    local media_root= ; # root fs path inside archive
    local media_meta= ; # meta-data descriptor file inside archive 
    
    media_type="${type-nspawn}"
    case "$media_type" in
        nspawn) # 'nspawn.sh' media type
            media_root="${root-}"
            media_meta="${meta-${ns_VAL[conf_file]}}"
            ;;
        plain) # simple tar.gz, such as ' archlinux-bootstrap-*.tar.gz'
            media_root="${root-}"
            media_meta="${meta-}"
            ;;
        aci) # https://github.com/appc/spec/blob/master/spec/aci.md
            media_root="${root-rootfs}"
            media_meta="${meta-manifest}"
            ;;
        *) 
            ns_log_fail "wrong media_type '$media_type'" 
            ;;
    esac
    
    declare -p ${!media_*}
}

#
ns_store_has_self() {
    [[ $url == ${image[url]} ]]
}

# inject store_* name space
ns_store_paths() { 
    local "$@" # url_*
    
    # unique name space: host/path
    local path="${url_host}${url_path}"
    
    # ensure default file name "_" for dir path
    [[ $path =~ ^.+/$ ]] && path="${path}_" 

    # switch to '#build#' folder during self image build
    ns_store_has_self && path="${ns_VAL[build_dir]}/$path" 
    
    # image archive download
    local store_archive="${ns_VAL[archive_dir]}/$path"
    
    # image extraction folder
    local store_extract="${ns_VAL[extract_dir]}/$path"
    
    # image descriptor file inside the archive
    local store_meta="$store_extract/${media_meta}"
    
    # image root fs folder path inside the archive
    local store_root="$store_extract/${media_root}"
    
    declare -p ${!store_*}
}

# resolve url into image storage description
ns_store_space() { 
    local "$@" ; ns_log_req url image
    
    eval "$(ns_url_parse)"
    eval "$(ns_store_media)"
    eval "$(ns_store_paths)"
    
    declare -p ${!url_*} ${!media_*} ${!store_*}
}
