
## host/instance network setup

### host

host system:
* uses `systemd-networkd`
* ensures net link is `wire0`
* joins `macvlan` with instances

### instance

instance system:
* expects 'mv-*' link name
* joins `macvlan` with host
