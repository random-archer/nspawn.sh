#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -r $___=@" ;
#!

#
# help system
#

ns_help_text() {
    local name=$(ns_a_prog_name)
    local help=
ns_a_define help << ns_EOF_HELP
----------------------------------------------------------------------------------

USAGE:
    $name run=command/action [arguments]

COMMAND / ACTION # DESCRIPTION

    list 
    
        unit # list systemd service units
        archive # list downloaded archive files
        extract # list extracted archive files
        machine # list machine resources
        network # list network resources

    unit
    
        create ... # create unit and container, pull images if missing
        delete ... # delete unit and container, keep images
        update ... # re-build: delete then create unit and container, no image pull
        upgrade    # similar to the update, only force fresh image check 
        remove ... # forcefully destroy unit and container resources, keep images
        
        erase  ... #
        inspire ... 
                                
        enable  ... # enable systemd service unit, reuse resources
        disable ... # disable systemd service unit, reuse resources
        
        start ... # start systemd service unit, reuse resources
        stop  ... # stop systemd service unit, reuse resources
            
EXAMPLE:

    $name run=unit/create name=default url=http://serv:3100/arch-base/latest.tar.gz
    $name run=unit/delete id=serv-arch-base-latest

----------------------------------------------------------------------------------
ns_EOF_HELP
     echo "$help"
}
