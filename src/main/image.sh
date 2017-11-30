#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# image management
#

# select compressor
ns_image_packer_tar_gz() { 
    type -p pigz && return 0
    type -p gzip && return 0
    ns_log_fail "missing packer" 
}

ns_image_dump() {
    local key= value=
    for key in "${!image[@]}" ; do value=${image[$key]}
          echo "$key : '$value'"
    done
}

# declare image context
ns_image_declare() {
    ns_log_note
    
    # archive properties map
    declare -A image=() 
    
    # execution parameters list
    declare -a image_entry=() 
    
    # overlay image url list, 
    # ordered, immediate parent only, no duplicate
    declare -a image_overlay=()
     
    # variable persistence group
    declare -r image_context=${!image*} 
    
    declare -p ${!image*}
} 

# define image resources
ns_image_define() {  
    ns_log_note

    [[ ${ns_STATE[image_define]} == yes ]] && ns_log_fail "duplicate" || ns_STATE[image_define]=yes   
                
    local "$@" ; ns_log_req --dbug url
    
    # assert
    ns_a_has_declare image

    image[url]="$url" # globally unique url
    
}

# populate image context
ns_image_append_entry() {
    local "$@" ; ns_log_req entry
    image_entry+=("$entry")
}

# populate image context
ns_image_append_overlay() {
    local "$@" ; ns_log_req entry
    image_overlay+=("$entry")
}

# image settings in the extract folder
ns_image_conf_file() { 
    echo "$store_extract/${ns_VAL[conf_file]}"
}

# persist memory image configuration into extract folder
ns_image_push_config() { 
    local "$@" ; ns_log_req --info store_extract
    
    local file="$(ns_image_conf_file)"
    
    ns_context_image_save 
}

# compress extract folder into archive file
ns_image_push_pack() {
    local "$@" ; ns_log_req store_archive store_extract
    
    ns_log_info "source: $(ns_a_dir_size path="$store_extract")"
    
    # ensure parents
    ns_a_mkpar file="$store_archive"
    
    case "$store_archive" in
        *.tar.gz)
            local packer="$(ns_image_packer_tar_gz)"
            local tar_opts="" ; #"--warning=no-file-ignored" # FIXME
            local store_tmpfile=$(mktemp) # avoid partial archive
            ns_a_sudo tar $tar_opts \
                --create \
                --use-compress-program="$packer" \
                --directory="$store_extract" \
                --file="$store_tmpfile" \
                --preserve-permissions "." # note "."
            ns_a_sudo mv --force "$store_tmpfile" "$store_archive"
            ;;
        *) 
            ns_log_fail "wrong archive format '$store_archive'"
            ;;
    esac
    
    # sync time stamp
    ns_a_sudo touch -r "$store_extract" "$store_archive"
        
    ns_log_info "target: $(ns_a_dir_size path="$store_archive")"
}

# upload archive file into remote url
ns_image_push_put() {
    local "$@" ; ns_log_req url store_extract
        
    ns_log_info "source: $store_archive"
    
    case "$url" in
        http*)
            eval "$(ns_curl_opts_put)"
            local curl_cmd=(curl "${curl_opts[@]}")
            local curl_text=$(ns_a_sudo "${curl_cmd[@]}" --upload-file "$store_archive" --url "$url")
            ;;
        file*)
            ns_a_mkpar file="$url_path"
            ns_a_sudo rsync -a --force "$store_archive" "$url_path"
            ;;
        s3*)
            false # TODO
            ;;
        bintray*)
            false # TODO
            ;;
        *)
            ns_log_fail "wrong scheme in url '$url'"
            ;;
    esac
    
    ns_log_info "target: $url"
}

# upload image resources into remote server
ns_image_push() { 
    local "$@"; ns_log_req --info url
    
    # resolve url into resource description
    eval "$(ns_store_space)"
    
    ns_image_push_config
    ns_image_push_pack
    ns_image_push_put
}

# recursively pull image tree
ns_image_pull_apply() { 
    local "$@"; ns_log_req --dbug file
    
    # new image context from file
    eval "$(ns_context_image_load)" 
    
    # recurse in the new context
    local url= ; for url in "${image_overlay[@]-}" ; do
        ns_image_pull
    done
}

# process image configuration
ns_image_pull_config() {  
    local "$@"; ns_log_req --dbug store_meta
    
    local file="$store_meta"
    
    case "$media_type" in
        nspawn) ns_image_pull_apply ;; # parse file 
        plain) true ;; # no meta in plain image
        aci) ns_log_warn "TODO aci" ;; 
        *) false ;;
    esac
}

# download archive file from remote url
ns_image_pull_get() { 
    local "$@" ; ns_log_req --dbug url

    # download only once
    if ns_a_array_contains array=image_memo_get entry="$url" ; then
        ns_log_dbug "archive is memento" ; return 0
    else
        image_memo_get+=("$url")
    fi

    # refresh download when enabled
    if [[ ${ns_STATE[image_pull_check]} == no && -e $store_archive ]] ; then
        ns_log_dbug "archive is present" ; return 0
    fi
    
    # ensure parents
    ns_a_mkpar file="$store_archive"
    
    case "$url" in
        http*)
            eval "$(ns_curl_opts_get)"
                        
            local curl_cmd=(curl "${curl_opts[@]}")

            # remote time stamp
            local head_text=$(ns_a_sudo "${curl_cmd[@]}" --head --url "$url")
            local time_stamp=$(ns_curl_parse_last_modified content="$head_text")
            local stamp_file="$store_archive.stamp" 
            ns_a_sudo touch --date="$time_stamp" "$stamp_file"

            # refresh when needed
            if ns_a_has_same_stamp path1="$stamp_file" path2="$store_archive" ; then
                 ns_log_dbug "archive is current"
            else
                ns_log_info "source: '$url'"
                local store_tmpfile=$(mktemp) # avoid partial download
                local curl_text=$(ns_a_sudo "${curl_cmd[@]}" --output "$store_tmpfile" --url "$url")
                ns_a_sudo mv -f "$store_tmpfile" "$store_archive" # atomic change
                ns_a_sudo touch -d "$time_stamp" "$store_archive" # sync with remote
                ns_log_info "target: '$store_archive'"
            fi
            ns_a_sudo rm -f "$stamp_file"
            ;;
        file*)
            ns_a_sudo rsync -a --force "$url_path" "$store_archive"
            ;;
        s3*)
            false # TODO
            ;;
        bintray*)
            false # TODO
            ;;
        *)
            ns_log_fail "wrong scheme in url: '$url'"
            ;;
    esac
}

# uncompress archive file into extract folder
ns_image_pull_unpack() {
    local "$@"; ns_log_req --dbug url
        
    # extract only once
    if ns_a_array_contains array=image_memo_unpack entry="$url" ; then
        ns_log_dbug "extract is memento" ; return 0
    else
        image_memo_unpack+=("$url")
    fi
       
    # refresh when changed
    if ns_a_has_same_stamp path1="$store_archive" path2="$store_extract" ; then
        ns_log_dbug "extract is current" ; return 0
    fi
     
    ns_log_info "source: $(ns_a_dir_size path="$store_archive")"
        
    # ensure parents
    ns_a_mkpar file="$store_extract"

    # avoid partial extract
    local store_tempdir=$(mktemp -d) 

    # extract archive                                     
    case "$media_type" in
        iso)
            false # TODO
            ns_a_sudo 7z e -o"$store_extract" "$store_archive" 
            ;;
        nspawn | plain | aci)
            local packer="$(ns_image_packer_tar_gz)"
            local tar_opts=""
            ns_a_sudo tar $tar_opts \
                     --extract \
                     --use-compress-program="$packer" \
                     --directory="$store_tempdir" \
                     --file="$store_archive" \
                     --preserve-permissions
            ;;
        *) 
            ns_log_fail "wrong archive '$store_archive'"
            ;;
    esac

    # copy content
    case ${ns_CONF[image_pull_copy]} in
        move) # atomic folder replace
            ns_a_sudo mv -f "$store_tempdir" "$store_extract"
            ;;
        sync) # individual file update
            ns_a_sudo rsync -a --force "$store_tempdir"/ "$store_extract" # note "/"
            ns_a_sudo rm -r -f "$store_tempdir" # cleanup
            ;;
        *)
            false; # trap
            ;;
    esac
    
    [[ ! -e $store_tempdir ]] # assert 
            
    # synchronize time stamp
    ns_a_sudo touch -r "$store_archive" "$store_extract"
         
    ns_log_info "target: $(ns_a_dir_size path="$store_extract")"
}

# resolve url into live resources
# download image archives, produce image extracts
ns_image_pull() { 
    local "$@"; ns_log_req --info url
    
    # resolve url into resource description
    eval "$(ns_store_space)"

    # optimization: remember processed images
    ns_a_has_declare image_memo_get || declare -a image_memo_get=()
    ns_a_has_declare image_memo_unpack || declare -a image_memo_unpack=()

    ns_image_pull_get
    ns_image_pull_unpack
    ns_image_pull_config
}
