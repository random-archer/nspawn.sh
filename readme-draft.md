
# nspawn.sh
Bash container engine for systemd-nspawn

[![travis status](https://travis-ci.org/random-archer/nspawn.sh.svg?branch=master)](https://travis-ci.org/random-archer/nspawn.sh/builds)
[![](https://tokei.rs/b1/github/random-archer/nspawn.sh)](https://github.com/random-archer/nspawn.sh)
[![](https://tokei.rs/b1/github/random-archer/nspawn.sh?category=files)](https://github.com/random-archer/nspawn.sh)

### install

arch
```
aur nspawn.sh
```

other
```
wget https://raw.githubusercontent.com/random-archer/nspawn.sh/master/nspawn.sh
chmod +x nspawn.sh
sudo mv nspawn.sh /usr/bin/nspawn.sh
```

### build image

examples
* [alp/base/build.sh](src/verify/image/alp/base/build.sh)
* [alp/serv/build.sh](src/verify/image/alp/serv/build.sh)
