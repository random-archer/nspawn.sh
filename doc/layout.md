
## resource locations

### systemd

managed by `systemd`

```
/etc/systemd/
    nspawn/
        <machine-id>.conf       # service profile
    system/
        <machine-id>.service    # service unit file

/var/lib/machines/
    <machine-id>/   # mount point for live container root fs
```

### nspawn.sh

managed by `nspawn.sh`

```
/etc/nspawn.sh/auth/
    <image-host>.conf   # image server access credentials

/etc/systemd/   # generated service files
    nspawn/
        <machine-id>.conf       # generated service profile
    system/
        <machine-id>.service    # generated service unit file

/var/lib/nspawn.sh
    archive/
        <image-host>/<image-path>/<image-name>.tar.gz   # image archive download
    extract/
        <image-host>/<image-path>/<image-name>.tar.gz/  # image extraction folder
    runtime/    # live containers
        <machine-id>/   #  resources for this container
            conf/
                nspawn.conf   # machine settings file
            work/
                ... # overlay fs working folder
            root/
                ... # transient machine root fs

```
