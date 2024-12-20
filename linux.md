# running on linux

## installing swift
use swiftly to install and manage swift toolchains
```
curl -L https://swiftlang.github.io/swiftly/swiftly-install.sh | bash
```

get the latest version of swift
```
swiftly install latest
```

verify the install was succesful
```
swift --version
```

## running the server
```
swift run -c release Server --target "<url>" --api-key "<token>"
```
