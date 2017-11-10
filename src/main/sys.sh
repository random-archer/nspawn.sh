#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!

#
# systemd functions
#

# invoke systemctl
ns_sys_ctl() {
    ns_log_note "$@"
    $(ns_a_suno) systemctl "$@"
}

# invoke systemctl w/o stderr
ns_sys_ctl_noerr() {
    ns_log_note "$@"
    2>/dev/null $(ns_a_suno) systemctl "$@"
}

# refresh unit definitions
ns_sys_reload() { 
    ns_log_info
    ns_sys_ctl daemon-reload || ns_log_warn "reload error"
}

# detect unit is present
ns_sys_has_unit() {
   local "$@" ; ns_log_req --dbug unit
   local line=$(ns_sys_ctl_noerr is-enabled "$unit" || true)
   [[ $line == "enabled" || $line == "disabled" ]]  
}

# unit is present and enabled
ns_sys_has_enabled() {
   local "$@" ; ns_log_req --dbug unit
   local line=$(ns_sys_ctl_noerr is-enabled "$unit" || true)
   [[ $line == "enabled" ]]
}

# unit is present and active
ns_sys_has_active() {
   local "$@" ; ns_log_req --dbug unit
   local line=$(ns_sys_ctl_noerr is-active "$unit" || true)
   [[ $line == "active" ]]
}

# idempotent enable unit
ns_sys_unit_enable() { 
    local "$@" ; ns_log_req --info unit
    &>/dev/null ns_sys_ctl enable "$unit" || true
}

# idempotent disable unit
ns_sys_unit_disable() { 
    local "$@" ; ns_log_req --info unit
    &>/dev/null ns_sys_ctl disable "$unit" || true
}

# idempotent start unit
ns_sys_unit_start() { 
    local "$@" ; ns_log_req --info unit
    &>/dev/null ns_sys_ctl start "$unit" || true
}

# idempotent stop unit
ns_sys_unit_stop() { 
    local "$@" ; ns_log_req --info unit
    &>/dev/null ns_sys_ctl stop "$unit" || true
}

# idempotent restart unit
ns_sys_unit_restart() { 
    local "$@" ; ns_log_req --info unit
    ns_sys_unit_stop
    ns_sys_unit_start
}

# idempotent unit enable/start
ns_sys_unit_activate() { 
    local "$@" ; ns_log_req --info unit
    ns_sys_unit_enable
    ns_sys_unit_start
}

# idempotent unit stop/disable
ns_sys_unit_deactivate() { 
    local "$@" ; ns_log_req --info unit
    ns_sys_unit_stop
    ns_sys_unit_disable
}
