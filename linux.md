# running on linux

## installing swift

https://www.swift.org/install/linux/

use swiftly to install and manage swift toolchains
```
curl -O https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz && \
tar zxf swiftly-$(uname -m).tar.gz && \
./swiftly init --quiet-shell-followup && \
. ~/.local/share/swiftly/env.sh && \
hash -r
```

verify the install was succesful
```
swift --version
```

## running the server
```
swift run -c release Server --target "<url>" --api-key "<token>"
```
