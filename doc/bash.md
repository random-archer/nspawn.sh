
## bash patterns

### module name space

each function uses name prefix `ns_`

each logical module is in file `module.sh`

each `module` function uses prefix `ns_module_`

### call convention

```
func() {
    local "$@" # inject arguments
    echo "name=$name" # use arguments
}

main() {
    # explicit parameter
    func name="test"
    # implicit parameter
    local name="test"
    func
}
```

### safe return status

to ignore return status: 

```
# ignore non-zero return value 
... || true
```

when using `set -e`, the following are safe:

```
# will not fail on test error, no tail
[[ test ]] && func
```

### un-safe return status

when using `set -e`, the following are NOT safe:

```
# will fail on test error, use tail suppressor
(( test )) && func || true
```

### value object return

```
func() {
    # value calculation
    local val_one=1
    local val_two=2
    # return matching scope
    declare -p ${!val*}
}

main() {
    # inject function result in local scope
    eval "$(func)"
    # use local values returned by function
    echo "val_one=$val_one val_two=$val_two"
}
```

### explicit return

since `return` refers to previous command status, always use explicit `return N`

### propagate command substitution error

manually: use solo assignment statement

```
func() {
    echo "data"
    false # error
}

main() {
    local data=; 
    data=$(func) # must be solo assignment statement
}
```

automatically: setup `sub shell` => `main shell` traps and signals 

### std file descriptors

in this application:
* `stdin` is not used
* `stdout` is used for function value return
* `stderr` is used for logging output and external command output

ensure that no "junk" appears in `stdout` 


### travis setup

to escape from obsolete travis `bash` version, use for test invocations:

```
nspawn_sh=$(type -p nspawn.sh)
test_script=".../build.sh"
"$BASH" "$nspawn_sh" "$test_script"

```
