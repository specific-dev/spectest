# spectest

This repository hosts only the prebuilt `spectest` CLI binaries published from
the (private) source repository.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/specific-dev/spectest/main/install.sh | sh
```

Detects your platform, downloads the matching release, verifies its checksum,
and installs `spectest` to `/usr/local/bin` when that is writable, otherwise to
`~/.local/bin` (telling you if that is not on your `PATH`). It never uses
`sudo` — a script piped from the internet should not be asking for your
password.

Options:

```bash
# a specific release
curl -fsSL https://raw.githubusercontent.com/specific-dev/spectest/main/install.sh | SPECTEST_VERSION=v0.2.36 sh

# somewhere else
curl -fsSL https://raw.githubusercontent.com/specific-dev/spectest/main/install.sh | SPECTEST_INSTALL_DIR=$HOME/bin sh
```

Supported platforms are **Linux x86_64** and **macOS (Apple Silicon)**;
anything else is refused with a message rather than a broken install.

Prefer to read it first? It is a single POSIX shell script:
[install.sh](install.sh).

### Manual download

Grab the tarball for your platform from the
[latest release](https://github.com/specific-dev/spectest/releases/latest):

- macOS (Apple Silicon): `spectest-<version>-aarch64-apple-darwin.tar.gz`
- Linux (x86_64): `spectest-<version>-x86_64-unknown-linux-musl.tar.gz`

```bash
tar -xzf spectest-*.tar.gz
chmod +x spectest && sudo mv spectest /usr/local/bin/
spectest --help
```

> **macOS note:** download with `curl` (as above), not your browser. Browser
> downloads get a quarantine flag, so Gatekeeper blocks the unsigned binary
> with *"Apple could not verify 'spectest' is free of malware."* `curl` does
> not set that flag, so the binary runs straight away. If you already
> downloaded it in a browser, clear the flag with
> `xattr -d com.apple.quarantine ./spectest`.

## Upgrade

```bash
spectest update          # pull and install the latest release in place
spectest update --check  # report whether a newer version is available
```
