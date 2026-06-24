# spectest

This repository hosts only the prebuilt `spectest` CLI binaries published from
the (private) source repository.

## Install

Download the tarball for your platform from the
[latest release](https://github.com/specific-dev/spectest/releases/latest):

- macOS (Apple Silicon): `spectest-<version>-aarch64-apple-darwin.tar.gz`
- Linux (x86_64): `spectest-<version>-x86_64-unknown-linux-musl.tar.gz`

```bash
tar -xzf spectest-*.tar.gz
chmod +x spectest && sudo mv spectest /usr/local/bin/
spectest --help
```

## Upgrade

```bash
spectest update          # pull and install the latest release in place
spectest update --check  # report whether a newer version is available
```
