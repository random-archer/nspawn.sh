#!/bin/bash

#
# ensure header of *.sh
#

# https://stackoverflow.com/questions/29613304/is-it-possible-to-escape-regex-metacharacters-reliably-with-sed
quote_regex() { 
    sed -e 's/[^^]/[&]/g; s/\^/\\^/g; $!a\'$'\n''\\n' <<<"$1" | tr -d '\n'
}
quote_subst() {
  IFS= read -d '' -r < <(sed -e ':a' -e '$!{N;ba' -e '}' -e 's/[&/\]/\\&/g; s/\n/\\&/g' <<<"$1")
  printf %s "${REPLY%$'\n'}"
}

# auto generated header
read -r -d '' header_text << 'HEADER'
#!/bin/bash
# Apache License 2.0
# Copyright 2016 Random Archer
# This file is part of https://github.com/random-archer/nspawn.sh

# import source once
___="source_${BASH_SOURCE//[![:alnum:]]/_}" ; [[ ${!___-} ]] && return 0 || eval "declare -gr $___=@" ;
#!
HEADER


set -u -e

readonly search_regex="#!(.+\n)(.*?)(#!\n)" # header pattern

readonly header_text
readonly header_regex=$(quote_regex "$header_text") # literal match
readonly header_subst=$(quote_subst "$header_text") # literal match

base="${BASH_SOURCE%/*}"
proj=$(cd "$base/.." && pwd)
code="$proj/src"
code_inst="$code/inst"
code_main="$code/main"
code_test="$code/test"

has_match() {
    local "$@" # path text
    local count=$(sed -z -n -r -e "/$text/p" "$path" | wc -l)
    (( $count > 0 ))
}

process_folder() {
    local "$@" # root
    for path in $(find "$root" -type f -name '*.sh') ; do
        echo "path=$path"
        if has_match path="$path" text="$search_regex" ; then
            echo "# present"
            if has_match path="$path" text="$header_regex" ; then
                echo "# matches"
                continue
            fi 
            echo "# update"
            sed -i -z -r -e "s/${search_regex}/${header_subst}\\n/" "$path"
        else
            echo "# prepend"
            temp=$(mktemp -u)
            echo "$header_text" | cat - "$path" > "$temp" && mv -f "$temp" "$path"        
        fi
    done
}

process_folder root="$code_main"
process_folder root="$code_test"
