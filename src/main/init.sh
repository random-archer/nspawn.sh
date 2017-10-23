#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

#
# setup shared variables
#

# protect value objects
ns_init_lock() {
    declare -r ns_VAL
    declare -r ns_help_CONF
    declare -r ns_help_BUILD
}

# global constants
ns_init_val() { 

    declare -g -A ns_VAL=()
            
    ns_VAL[machine_dir]="/var/lib/machines" # system container mount folder
    ns_VAL[profile_dir]="/etc/systemd/nspawn" # system container settings folder
    ns_VAL[service_dir]="/etc/systemd/system" # system service units folder
    
    ns_VAL[conf_dir]="conf" # instance configuration files folder
    ns_VAL[root_dir]="root" # instance root file system folder
    ns_VAL[work_dir]="work" # instance overlay working folder
    ns_VAL[zoom_dir]="zoom" # instance overlay bottom folder

    ns_VAL[build_data]="/usr/lib/nspawn.sh/state" # persisted container build state folder
                
    ns_VAL[etc_dir]="/etc/nspawn.sh" # nspawn config folder
    ns_VAL[conf_file]="nspawn.conf" # persisted container descriptor file
    ns_VAL[etc_conf_file]="${ns_VAL[etc_dir]}/${ns_VAL[conf_file]}" # default settings
    
    ns_VAL[home_dir]="${HOME-}/.nspawn.sh"
    ns_VAL[build_dir]="#build#" # image resources during build (relative) 

    # service.nspawn section [Exec]                                                
    ns_VAL[prof_exec_override]="Boot=|User=|KillSignal=|Parameters=|Capability=|DropCapability=" 
    ns_VAL[prof_exec_cumulate]="Environment="
                        
    # service.nspawn section [Files]                                                
    ns_VAL[prof_files_override]="ReadOnly=" 
    ns_VAL[prof_files_cumulate]="Bind=|BindReadOnly="

    # service.nspawn section [Network]                                                
    ns_VAL[prof_network_override]="Zone=|Bridge=|VirtualEthernet=|VirtualEthernetExtra=|MACVLAN=" 
    ns_VAL[prof_network_cumulate]="Port="
    
    # service.nspawn keys with new values replacing old                                                
    ns_VAL[prof_all_override]="${ns_VAL[prof_exec_override]}|${ns_VAL[prof_files_override]}|${ns_VAL[prof_network_override]}" 
                            
    # service.nspawn keys to remove during build                                                
    ns_VAL[prof_build_filter]="Boot=|Parameters=|KillSignal=|Bind=|BindReadOnly=|Zone=|Port=|Bridge=|MACVLAN="                                                

    # service.nspawn keys: group by section                                                
    ns_VAL[prof_exec]="${ns_VAL[prof_exec_override]}|${ns_VAL[prof_exec_cumulate]}" # section [Exec]
    ns_VAL[prof_files]="${ns_VAL[prof_files_override]}|${ns_VAL[prof_files_cumulate]}" # section [Files]
    ns_VAL[prof_network]="${ns_VAL[prof_network_override]}|${ns_VAL[prof_network_cumulate]}" # section [Network]
    
    # image and machine storage    
    ns_VAL[storage_dir]="/var/lib/nspawn.sh" # root of nspawn.sh image/machine resources 
    ns_VAL[archive_dir]="${ns_VAL[storage_dir]}/archive" # images download folder
    ns_VAL[extract_dir]="${ns_VAL[storage_dir]}/extract" # uncompressed images folder
    ns_VAL[locator_dir]="${ns_VAL[storage_dir]}/locator" # resource location folder, find machine by id
    ns_VAL[runtime_dir]="${ns_VAL[storage_dir]}/runtime" # live machine instance runtime container folders
    
}

# global mutable state
ns_init_state() { 
    
    declare -g -A ns_STATE=() # transient variables
    
    ns_STATE[main]=none # mode of script execution
    ns_STATE[terminate]=ok # mode of script termination
    
    ns_STATE[proxy]=no # proxy was configured
    ns_STATE[proxy_http]="" # discovered plain proxy
    ns_STATE[proxy_https]="" # discovered secure proxy
    
    ns_STATE[do_image]=no # command memento
    ns_STATE[do_alter]=no # command memento
    ns_STATE[do_push]=no # command memento
    ns_STATE[do_exit]=no # command memento
    ns_STATE[do_run]=no # command memento
                
    ns_STATE[image_define]=no # image was initialized
    ns_STATE[machine_define]=no # machine was initialized
    
    ns_STATE[build_create]=no # build context was created
    ns_STATE[build_delete]=no # build context was deleted
    
    ns_STATE[image_pull_check]=no # pull checks for newer images
    
}


# global configuration
ns_init_config() { 
    
    declare -g -A ns_CONF=() # global configuration
    declare -g -A ns_help_CONF=() # help for global configuration
    declare -g -A ns_help_BUILD=() # help for build commands
        
    ns_CONF[log_level]=1 # logger level at startup
    ns_help_CONF[log_level]="log level: FAIL=0 WARN=1, INFO=2, DBUG=3, NOTE=4"
        
    ns_CONF[base_dir]=invalid
    ns_help_CONF[base_dir]="folder containing 'build.sh' script, to access build resources"
        
    ns_CONF[image_pull_copy]="sync"
    ns_help_CONF[image_pull_copy]="\
        'move' : atomic folder replace, not safe for update; \
        'sync' : individual file update, safe for live instance update; \
    "
                        
    ns_CONF[curl_opts]="--insecure --silent --show-error --fail --location"
    ns_help_CONF[curl_opts]="curl invocation options for both get and put "
                                                
    ns_CONF[auth_path]="${ns_VAL[etc_dir]}/auth:${ns_VAL[home_dir]}/auth"
    ns_help_CONF[auth_path]="host login credential files search path"
    
    # developer options
    ns_CONF[dbug_trap_skip_exit]=no
        
    # unit.service file generator
    ns_CONF[unit_After]=network-online.target
    ns_CONF[unit_Requires]=network-online.target
    ns_CONF[unit_WantedBy]=multi-user.target
    ns_CONF[unit_Slice]=machine.slice
    ns_CONF[unit_CPUQuota]=
    ns_CONF[unit_KillMode]=mixed
    ns_CONF[unit_RestartSec]=1s
    ns_CONF[unit_TimeoutStartSec]=3s
    ns_CONF[unit_TimeoutStopSec]=3s
    ns_CONF[unit_RestartForceExitStatus]=133 # reboot
    ns_CONF[unit_RestartPreventExitStatus]=
    ns_CONF[unit_DeviceAllow]=
    
    ns_CONF[unit_nspawn_options]="--quiet --keep-unit --register=yes --link-journal=host"
    ns_help_CONF[unit_nspawn_options]="options for systemd-nspawn invocation in service unit"

    ns_CONF[unit_runtime_persist]=no
    ns_help_CONF[unit_runtime_persist]="do not remove container transient root fs on service stop"
                                
    ns_CONF[build_unit_keep]=no
    ns_help_CONF[build_unit_keep]="do not remove transient build generated service units to debug"
        
    ns_CONF[build_store_reset]=yes
    
    ns_CONF[build_import_env]=yes
    ns_help_CONF[build_import_env]="import machine env vars into build script environment"
        
    ns_CONF[nspawn_params]=
    ns_help_CONF[nspawn_params]="unit.nspawn profile override entries"
            
    ns_CONF[proxy_mode]="auto"
    ns_help_CONF[proxy_mode]="\
        auto: try ... ; \
        none: disable proxy ; \
        config: use configured values only ; \
        inherit: use environment variables only ; \
    "
        
    ns_CONF[proxy_http]="http://proxy:3128"
    ns_help_CONF[proxy_http]="configured plain http proxy url"
    
    ns_CONF[proxy_https]="http://proxy:3130"
    ns_help_CONF[proxy_https]="configured secure http proxy url"
        
    ns_CONF[proxy_on_get]=yes
    ns_help_CONF[proxy_on_get]="enable proxy during image pull/download"
    
    ns_CONF[proxy_on_put]=no
    ns_help_CONF[proxy_on_put]="enable proxy during image upload/push"
                                                                          
    ns_help_BUILD[CONFIG]="key=value, ... # control $(ns_a_prog_name) settings, such as proxy setup, logging, etc."
    ns_help_BUILD[IMAGE]="url=... # declare image url, which is both image id and the upload location"
    ns_help_BUILD[PULL]="url=... # transitively download remote image and make it part of container overlay"
    ns_help_BUILD[COPY]="src=... dst=... | path=a:b:c:... # copy local resource into the container"
    ns_help_BUILD[DEF]="path=... text=... # provision in-line file in the container"
    ns_help_BUILD[GET]="url=... path=... type=... # download remote file and place in the container"
    ns_help_BUILD[ENV]="key=value, ... # synonym for SET Environment=key=value"
    ns_help_BUILD[CAP]="add=C1,C2,... del=C3,C4... # synonym for SET Capabilities='C1 C2 ...' DropCapabilities='C3 C4 ...'"
    ns_help_BUILD[SH]="command # synonym for RUN sh -c 'command'"
    ns_help_BUILD[EXEC]="command # synonym for SET Boot=no  Parameters=command"
    ns_help_BUILD[INIT]="command # synonym for SET Boot=yes Parameters=command"
    ns_help_BUILD[SET]="see://[systemd.nspawn — Container settings]  # configure container execution parameters"
    ns_help_BUILD[RUN]="command # invoke user build command inside the container"
    ns_help_BUILD[PUSH]="# push image result to the declared url"
    ns_help_BUILD[EXIT]="# build termination statement"
    
}

# setup shared variables 
ns_init_all() {
    ns_init_val
    ns_init_state
    ns_init_config
}
