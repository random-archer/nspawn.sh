#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# maintenance functions
#

# enumerate containers in runtime
ns_keep_runtime_list() {
    ns_log_dbug
    # configured containers
    local runtime_dir="${ns_VAL[runtime_dir]}"
    ns_a_sudo ls -1 "$runtime_dir"
}

# enumerate images used in all of runtime
ns_keep_image_list() {
    ns_log_dbug
    
    local image_list=()
    
    eval "$(ns_machine_declare)"
    
    # iterate runtime machines
    local IFS=$'\n'
    local name=; for name in $(ns_keep_runtime_list) ; do 
        unset IFS
        
        # machine settings
        local file=$(ns_conf_runtime_conf_file id="$name")
        
        # inject machine settings
        eval "$(ns_context_machine_load)" # file 

        # iterate machine images
        local entry=; for entry in "${machine_overlay[@]-}" ; do
            # keep unique
            if ns_a_array_contains array=image_list ; then
                continue
            else
                image_list+=("$entry")
                echo "$entry"
            fi
        done
        
    done
}

# enumerate image store paths in runtime
ns_keep_storage_list() {
    ns_log_dbug

    eval "$(ns_image_declare)"

    # iterate images
    local IFS=$'\n'
    local url=; for url in $(ns_keep_image_list) ; do 
        unset IFS
        
        # no build context
        image[url]="invalid"
        
        # image => store_*
        eval "$(ns_store_space)"
        
        # keep these images
        echo "$store_archive"
        done
}

# enumerate image store paths with parent trees
ns_keep_storage_explode() {
    local IFS=$'\n'
    local path=; for path in $(ns_keep_storage_list) ; do 
        unset IFS
        ns_a_path_explode # path
    done
}

# FIXME removes #build# folder
# FIXME provide integration test
# remove unused archive and extract image resources
ns_keep_cmd_clean() {
    ns_log_info "start"
    
    # stored images
    local archive_dir="${ns_VAL[archive_dir]}"
    
    # stored extracts
    local extract_dir="${ns_VAL[extract_dir]}"
    
    # sudo on demand
    local suno=$(ns_a_suno)
        
    # command report
    local report_dir=$(ns_conf_report_dir)
    local report_file="$report_dir/$FUNCNAME.log"
    ns_a_sudo mkdir -p "$report_dir"
    
    # remove unused archive and extract image resources 
    local count=$(
        # combine unused with active duplicates
        ( 
            # iterate archive folder
            $suno find "$archive_dir" -type d -print
            # inject exclusion set
            echo "$(ns_keep_storage_explode)"
            # twice, to generate duplicates
            echo "$(ns_keep_storage_explode)"
        ) | 
        # 'uniq' needs sorted duplicates
        sort | 
        # 'print unique' keeps only unused
        uniq -u | 
        # generate report
        $suno tee "$report_file" |
        # discard unused archive
        tee >( xargs -I @ $suno rm -rf "@" )  | 
        # map archive to extract 
        sed -e "s|$archive_dir|$extract_dir|" | 
        # discard unused extract
        tee >( xargs -I @ $suno rm -rf "@" )  |
        # generate stats
        wc --lines
    )
    
    ns_log_info "finish: count='$count' report='$report_file'"
    
}

# keeper service/timer name
ns_keep_unit_name() {
    echo "$(ns_a_prog_name)-keeper"
}

# keeper service
ns_keep_unit_service_text() {
    local text=;
ns_a_define text << EOF
#
# $(ns_a_date_time) $(ns_a_prog_name) keeper service
#
[Unit]
Description=$(ns_a_prog_name) keeper service
After=local-fs.target network.target
#
[Service]
Type=oneshot
ExecStart=$(type -p $(ns_a_prog_name)) run=keep/clean log_level=2
#
[Install]
WantedBy=multi-user.target
#
EOF
    printf "%q" "$text"
}

# keeper timer
ns_keep_unit_timer_text() {
    local text=;
ns_a_define text << EOF
#
# $(ns_a_date_time) $(ns_a_prog_name) keeper timer
#
[Unit]
Description=$(ns_a_prog_name) keeper timer
After=local-fs.target network.target
#
[Timer]
OnCalendar=${ns_CONF[keeper_timer_calendar]}
#
[Install]
WantedBy=timers.target
#
EOF
    printf "%q" "$text"
}

#
ns_keep_cmd_install() {
    ns_log_info
    #
    ns_keep_unit_resource mode=create
    #
    local unit=$(ns_keep_unit_timer_name)
    ns_sys_unit_activate
    ns_sys_has_enabled && ns_sys_has_active || ns_log_warn "install error"
}

#
ns_keep_cmd_remove() {
    ns_log_info
    #
    local unit=$(ns_keep_unit_timer_name)
    ns_sys_unit_deactivate 
    ! ns_sys_has_unit  || ns_log_warn "remove error"
    #
    ns_keep_unit_resource mode=delete
}

#
ns_keep_unit_timer_file() {
    ns_conf_timer_file id=$(ns_keep_unit_name)
}

ns_keep_unit_timer_name() {
    ns_conf_timer_name id=$(ns_keep_unit_name)
}

#
ns_keep_unit_service_file() {
    ns_conf_service_file id=$(ns_keep_unit_name)
}

# create/delete keeper units
ns_keep_unit_resource() { 
    local "$@" ; ns_log_req --dbug mode
     
    ns_a_resource file=$(ns_keep_unit_service_file) text=$(ns_keep_unit_service_text)
    ns_a_resource file=$(ns_keep_unit_timer_file) text=$(ns_keep_unit_timer_text)
    ns_sys_reload
}
