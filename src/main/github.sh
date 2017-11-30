#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# remote github api transport
#

# url mapping rules:
# scheme://host/path
# github://owner/repo/rest/file.ext
# scheme -> github
# host   -> owner, user or organization 
# repo   -> repo, first path segment
# rest/file.ext -> item, release tag, item=rest~file.ext
#
# mapping example:
# github://random-archer/nspawn.repo/base/arch/2017-11-20.tar.gz
# GET https://github.com/random-archer/nspawn.repo/archive/base~arch~2017-11-20.tar.gz
# POST https://uploads.github.com/repos/random-archer/nspawn.repo/releases/base~arch~2017-11-20.tar.gz/assets?name=base~arch~2017-11-20.tar.gz

###

# extract github_*: owner, repo, item
ns_github_map_url() {
    local "$@" # url
    eval "$(ns_url_parse)"
    [[ $url_scheme == "github" ]]
    local github_owner=${url_host}
    local IFS='/'
    local path_list=( $url_path )
    unset IFS
    (( ${#path_list} >= 3 ))
    local github_repo=${path_list[1]}
    local path_list=(${path_list[@]:2})
    local github_item=$(ns_a_array_join array=path_list separ='~')
    declare -p ${!github_*}
}

# substitute owner, repo, item
ns_github_subst() {
    local "$@" # url github_url
    eval "$(ns_github_map_url)" # github_*
    local github_url=${github_url//:owner/$github_owner}
    local github_url=${github_url//:repo/$github_repo}
    local github_url=${github_url//:item/$github_item}
    echo "$github_url"
}

# build GET url
# https://github.com/:owner/:repo/archive/:item
ns_github_url_get() {
    local "$@" # url
    local github_url="https://github.com/:owner/:repo/archive/:item"
    ns_github_subst
}

#
ns_github_do_get() {
    local "$@"
        
}

# build POST url
# https://uploads.github.com/repos/:owner/:repo/releases/:item/assets?name=:item
ns_github_url_put() {
    local "$@" # url
    local github_url="https://uploads.github.com/repos/:owner/:repo/releases/:item/assets?name=:item"
    ns_github_subst
}

#
ns_github_do_put() {
    local "$@"
    
    curl \
     "https://api.github.com/repos/random-archer/nspawn.repo/releases"

#    curl \
#     --request DELETE \
#     --header "Authorization: token $token" \
#     --header "Content-Type: application/zip" \
#     --data-binary @readme.md \
#     "https://api.github.com/repos/random-archer/nspawn.repo/releases/assets/5312495"


#    curl \
#     --request POST \
#     --header "Authorization: token $token" \
#     --data '{ "tag_name" : "hello-kitty" }' \
#     "https://api.github.com/repos/random-archer/nspawn.repo/releases"
                
#    curl \
#     --request POST \
#     --header "Authorization: token $token" \
#     --header "Content-Type: application/zip" \
#     --data-binary @readme.md \
#     "https://uploads.github.com/repos/random-archer/nspawn.repo/releases/8478342/assets?name=test.zip"
    
     
}
