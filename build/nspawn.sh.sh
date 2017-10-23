#! /bin/bash

set -e -u

commit() {
    
    local base="$1"

    cd "$base"

    git add -A

    git status 

    local message=$(git status --short)
    
    git commit --message "$message"
    
    git push
    
}

"${BASH_SOURCE%/*}/test.sh"

commit "${BASH_SOURCE%/*}"
