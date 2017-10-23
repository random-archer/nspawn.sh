
### image media type

foreign image archive meta data can be specified
by "extended url convention", via url `#fragment`

supported fragment parameters:
* `type`: one of supported `nspawn.sh` media types
* `root`: folder of root fs inside the archive
* `meta`: path to the image configuration file inside the archive

for example, this is `plain` tar gz file with root fs at `root.x86_64`
```
    http://mirror.archlinux.io/archlinux-bootstrap-$version-x86_64.tar.gz
```

proper url with "image media" meta data will look like:
```
url=http://mirror.archlinux.io/archlinux-bootstrap-$version-x86_64.tar.gz#type=plain&root=root.x86_64
``` 
