
### overlay file system

error:
```
mount: /var/lib/machines/nspawn.sh-41ee9d76a9c94172b3685936724b949e: wrong fs type, bad option, bad superblock on overlay, missing codepage or helper program, or other error.
```

happens when trying to mount `overlay` fs inside another `overlay` fs

the work around is to `Bind` instance overlay targets `/var/lib/...` to the non-overlay storage
