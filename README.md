# spectest

## Installation

Install the CLI by running:

```bash
curl -fsSL https://raw.githubusercontent.com/specific-dev/spectest/main/install.sh | sh
```

### Manual installation

Grab the tarball for your platform from the
[latest release](https://github.com/specific-dev/spectest/releases/latest):

- macOS (Apple Silicon): `spectest-<version>-aarch64-apple-darwin.tar.gz`
- Linux (x86_64): `spectest-<version>-x86_64-unknown-linux-musl.tar.gz`

```bash
tar -xzf spectest-*.tar.gz
chmod +x spectest && sudo mv spectest /usr/local/bin/
spectest --help
```

## Updating the CLI

```bash
spectest update
```
