#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# container settings resolver
#

# inject collected log as is
ns_resolve_export_log() {
    ns_log_note "${resolve_log[@]}"
    
    ns_a_has_declare machine_log
        
    machine_log+=("${resolve_log[@]}")
}

# merge collected entries into machine
ns_resolve_export_entry() { 
    ns_log_note "${resolve_entry[@]-}"
    
    ns_a_has_declare machine_entry
    
    # list values set
    local -a Environment=() BindReadOnly=() Bind=() Port=()
    
    # solo values map
    local -A override 
    
    local entry= ; for entry in "${resolve_entry[@]-}" ; do
        eval "$(ns_parse_entry)" # key val
        
        # list values, additive
        [[ $entry == Environment= ]] && Environment=() && continue #
        [[ $entry =~ Environment= ]] && Environment+=("$entry") && continue
        [[ $entry == BindReadOnly= ]] && BindReadOnly=() && continue #
        [[ $entry =~ BindReadOnly= ]] && BindReadOnly+=("$entry") && continue
        [[ $entry == Bind= ]] && Bind=() && continue #
        [[ $entry =~ Bind= ]] && Bind+=("$entry") && continue
        [[ $entry == Port= ]] && Port=() && continue #
        [[ $entry =~ Port= ]] && Port+=("$entry") && continue
        
        # solo values, override
        [[ $entry =~ ${ns_VAL[prof_all_override]} ]] && {
            [[ $val == "" ]] && unset -v override["$key"] && continue # emtpy to erase
            [[ $val != "" ]] && override["$key"]="$val" && continue
        }
         
        # keep last
        [[ $entry ]] && ns_log_fail "wrong entry: '$entry'"
        
    done
    
    local key= value= ; for key in "${!override[@]}" ; do value="${override[$key]}"
         machine_entry+=("$key=$value")
    done
    
    machine_entry+=(
        "${Environment[@]-}"
        "${BindReadOnly[@]-}"
        "${Bind[@]-}" 
        "${Port[@]-}"
    )
    
}

# remove duplicate images, keep deep first
ns_resolve_export_overlay() {
    ns_log_note "${resolve_overlay[@]-}"
    
    ns_a_has_declare machine_overlay
        
    local entry=; for entry in "${resolve_overlay[@]-}" ; do
        if ! ns_a_array_contains array=machine_overlay ; then
            machine_overlay+=("$entry")
        fi
    done
}

# override or collate machine settings 
ns_resolve_export() { 
    ns_log_dbug
    ns_resolve_export_log
    ns_resolve_export_entry
    ns_resolve_export_overlay
}

# record into log
ns_resolve_collect_log() {  
    local "$@" 
    ns_log_note "$entry" 
    resolve_log+=("#$entry")
}

# record into entry
ns_resolve_collect_entry() { 
    local "$@" 
    ns_log_note "$entry" 
    resolve_entry+=("$entry")
}

# record into both log and entry
ns_resolve_collect_record() { 
    local "$@" # entry
    ns_resolve_collect_log entry="   $entry" # keep space
    ns_resolve_collect_entry 
}


# collect settings from conf_file
ns_resolve_apply() { 
    ns_log_req --dbug file
    
    # 'next' image context 
    eval "$(ns_context_image_load)"
    
    # recurse depth first
    local url=; for url in "${image_overlay[@]-}" ; do
        [[ $url ]] || continue # TODO find why empty url
        ns_resolve_collect
    done
    
    # origin comment
    ns_resolve_collect_log entry=" image-source: ${image[url]}" 
    
    # 'next' image entries
    local entry= ; for entry in "${image_entry[@]-}" ; do
        ns_resolve_collect_record   
    done
}

# recursively discover machine settings
ns_resolve_collect() {
    local "$@" ; ns_log_req --dbug url
    
    # url => store_*
    eval "$(ns_store_space)"
    
    local file="$store_meta"
    
    # recurse first
    case "$media_type" in
        nspawn) ns_resolve_apply ;;
        plain)ns_log_dbug "plain has no media type" ;;
        aci) ns_log_warn "TODO aci" ;;
        *) false ;; # trap 
    esac
    
    # append last
    resolve_overlay+=("$url") 
}

# inject proxy environment into container
ns_resolve_proxy() {
     
    # origin comment
    ns_resolve_collect_log entry=" proxy-inject: mode=${ns_CONF[proxy_mode]}" 
     
    local entry= ; for entry in $(ns_proxy_env_text) ; do
        ns_resolve_collect_record
    done 
}

# inject command line parameters
ns_resolve_command() { 
    ns_log_note
    
    ns_resolve_collect_log entry=" command-line:" # origin comment
    
    local IFS=$';'
    local nspawn_params=( ${ns_CONF[nspawn_params]-} )
    unset IFS
    
    local entry= ; for entry in "${nspawn_params[@]-}" ; do
        ns_log_dbug "$entry"
        ns_resolve_collect_record # entry
    done
}

# inject settings form config/command
ns_resolve_override() { 
    ns_resolve_proxy
    ns_resolve_command
}

# resolve machine settings from image tree and overrides
ns_resolve_machine() { 
    ns_log_req --dbug url
    
    # resolution results
    declare resolve_log=()
    declare resolve_entry=()
    declare resolve_overlay=()
        
    ns_resolve_collect 
    ns_resolve_override
    ns_resolve_export
}
