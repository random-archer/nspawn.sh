#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

#
# systemd unit.nspawn and unit.service file generator
#

# discover system unit identity
ns_unit_args() { 
    [[ ${url-} && ${name-} ]] && echo "url=$url name=$name" && return 0 || true
    [[ ${id-} ]] && ns_unit_locator_load apply=ns_unit_locator_apply && return 0 || true
    ns_log_fail "can not resolve unit: provide 'id' or 'url' + 'name'"
}

ns_unit_locator_apply() {
    echo "url=$locator_url name=$locator_name"
}

#
# unit locator generator 
#

# generate machine_id.conf file
ns_unit_locator_text() { 
    local locator_id=${machine[id]}
    local locator_date=$(ns_a_date_time)
    local locator_comment="map from 'id' into 'url' + 'name'"
    declare -p ${!locator_*}
}

# 
ns_unit_locator_file() {
    local "$@" 
    echo "${ns_VAL[locator_dir]}/${machine[id]}.conf"
}

ns_unit_locator_load() {
    local "$@" 
    source $(ns_unit_locator_file)
    $apply
}

ns_unit_locator_save() {
    local file=$(ns_unit_locator_file)
    ns_unit_locator_text | ns_a_save
}

ns_unit_locator_rm() {
    local file=$(ns_unit_locator_file)
    ns_a_sudo rm -f "$file"
}

#
# unit profile generator
#

# generate /etc/systemd/nspawn/<machine-id>.nspawn content
ns_unit_profile_text() {
    local id=${machine[id]}
    local text= entry=
ns_a_define text << ns_unit_EOF_PROFILE
#
# $(ns_a_date_time) $(ns_a_prog_name) container profile
#
#[Log]
$(
for entry in "${machine_log[@]-}" ; do 
    echo "$entry" 
done
)
#
[Exec]
$(for entry in "${machine_entry[@]-}" ; do [[ $entry =~ ${ns_VAL[prof_exec]} ]] && echo "$entry" || continue ; done)
#
[Files]
$(for entry in "${machine_entry[@]-}" ; do [[ $entry =~ ${ns_VAL[prof_files]} ]] && echo "$entry" || continue ; done)
#
[Network]
$(for entry in "${machine_entry[@]-}" ; do [[ $entry =~ ${ns_VAL[prof_network]} ]] && echo "$entry" || continue ; done)
#
ns_unit_EOF_PROFILE
    echo "$text"
}

ns_unit_profile_save() {
    local file="${machine[profile_file]}"
    ns_unit_profile_text | ns_a_save
}

ns_unit_profile_rm() {
    local file="${machine[profile_file]}"
    ns_a_sudo rm -f "$file" 
}

#
# unit service generator 
# 

ns_unit_service_overlay() {
    local overlay=$(ns_overlay_extract)
    local entry= ; for entry in ${overlay//':'/' '} ; do
        echo "AssertPathExists=$entry"
    done 
}

ns_unit_service_create() {
    local cmd_mkdir="$(type -p mkdir)"
    local point="${machine[machine_dir]}"
    true && {
        echo "ExecStartPre=$cmd_mkdir -p ${machine[root_dir]}"
        echo "ExecStartPre=$cmd_mkdir -p ${machine[work_dir]}"
    }
    echo "ExecStartPre=$(ns_overlay_create_cmd)"
}

ns_unit_service_delete() {
    local cmd_rm="$(type -p rm)"
    local point="${machine[machine_dir]}"
    echo "ExecStopPost=$(ns_overlay_delete_cmd)"
    [[ "${ns_CONF[unit_runtime_persist]}" == yes ]] || {
        echo "ExecStopPost=$cmd_rm -r -f ${machine[root_dir]}"
        echo "ExecStopPost=$cmd_rm -r -f ${machine[work_dir]}"
    }
}

ns_unit_service_invoke() {
    local cmd_nspawn="$(type -p systemd-nspawn)"
    local machine_id=${machine[id]}
    local nspawn_options=${ns_CONF[unit_nspawn_options]}
    echo "ExecStart=$cmd_nspawn --machine=$machine_id $nspawn_options"
}

ns_unit_service_text_device() { # parse: unit_DeviceAllow="char-tty0 rwm;char-ttyUSB rwm;"
    [[ ${ns_CONF[unit_DeviceAllow]} ]] || return 0
    local IFS=';' ; local entry_list=(${ns_CONF[unit_DeviceAllow]-}) ; unset IFS # parse param
    local rx_space="^[[:space:]]*$" # invalid
    local entry= ; for entry in "${entry_list[@]-}" ; do
        [[ $entry =~ $rx_space ]] && continue # drop empty
        echo "DeviceAllow=$entry"
    done
}

# generate /etc/systemd/system/machine.service file
ns_unit_service_text() { 
    local machine_id=${machine[id]}
    local text= entry=
ns_a_define text << ns_unit_EOF_SERVICE
#
# $(ns_a_date_time) $(ns_a_prog_name) container service
#
[Unit]
Description=$(ns_a_prog_name)/$machine_id
After=${ns_CONF[unit_After]}
Requires=${ns_CONF[unit_Requires]}
#
# Container Mount:
AssertPathExists=${machine[machine_dir]}
#
# Container Profile:
AssertPathExists=${machine[profile_file]}
#
# Container Overlay:
$(for entry in "$(ns_unit_service_overlay)" ; do echo "$entry" ; done)
#
[Service]
KillMode=${ns_CONF[unit_KillMode]}
Slice=${ns_CONF[unit_Slice]}
CPUQuota=${ns_CONF[unit_CPUQuota]}
RestartSec=${ns_CONF[unit_RestartSec]}
TimeoutStartSec=${ns_CONF[unit_TimeoutStartSec]}
TimeoutStopSec=${ns_CONF[unit_TimeoutStopSec]}
SyslogIdentifier=$machine_id
RestartForceExitStatus=${ns_CONF[unit_RestartForceExitStatus]}
RestartPreventExitStatus=${ns_CONF[unit_RestartPreventExitStatus]}
$(ns_unit_service_text_device)
#
# Container Create:
$(for entry in "$(ns_unit_service_create)" ; do echo "$entry" ; done)
#
# Container Invoke:
$(for entry in "$(ns_unit_service_invoke)" ; do echo "$entry" ; done)
#
# Container Delete:
$(for entry in "$(ns_unit_service_delete)" ; do echo "$entry" ; done)
#
[Install]
WantedBy=${ns_CONF[unit_WantedBy]}
#
ns_unit_EOF_SERVICE
     echo "$text"
}

ns_unit_service_save() {
    local file=${machine[service_file]}
    ns_unit_service_text | ns_a_save 
}

ns_unit_service_rm() {
    local file=${machine[service_file]}
    ns_a_sudo rm -f "$file"
}

### unit management 

# provision service unit support files
ns_unit_resource() { 
    local "$@" ; ns_log_req --dbug mode
    
    local conf_file=${machine[conf_file]}
    case "$mode" in
        create)
            ns_context_machine_save file="$conf_file"
            ns_unit_locator_save
            ns_unit_profile_save
            ns_unit_service_save
            ;;
        delete)
            ns_a_sudo rm -f "$conf_file"
            ns_unit_locator_rm
            ns_unit_profile_rm
            ns_unit_service_rm
            ;;
        skip) ;;
        *) ns_log_fail "wrong mode '$mode'" ;;
    esac 
}


ns_unit_reload() { # refresh service definition
    ns_log_info
    ns_sys_ctl daemon-reload
}
