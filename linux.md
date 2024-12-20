# running on linux

## installing swift
- use swiftly to install and manage swift toolchains:
```
curl -L https://swiftlang.github.io/swiftly/swiftly-install.sh | bash
```

- run `swiftly install latest` to get the latest version of swift
- verify succesful installation by running `swift --version`

## running the server
- `swift run -c release Server --target "<url>" --api-key "<token>"`
