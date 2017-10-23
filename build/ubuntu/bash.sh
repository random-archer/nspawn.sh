#!/bin/bash

#
# travis bash build for ubuntu
#

set -e -u

bash_check() {
    local major=${BASH_VERSINFO[0]}
    local minor=${BASH_VERSINFO[1]}
    if (( major >= 4 )) && (( minor >= 4 )) ; then
        exit
    fi
}

bash_build() {
    # travis has this
    #sudo apt-get install -y build-essential
    
    mkdir -p "$BASH_HOME" 
    cd "$BASH_HOME"
    
    local version=4.4.12
    wget -nc http://ftp.gnu.org/gnu/bash/bash-${version}.tar.gz
    tar xf bash-${version}.tar.gz
    cd bash-${version}
    
    ./configure --prefix="$BASH_HOME"
    make
    make install
}

bash_has_local() {
    [[ -e "$BASH_HOME/bin/bash" ]]
}

[[ ${BASH_HOME-} ]] || declare -r BASH_HOME="/tmp/bash_home"

bash_has_local || bash_build
