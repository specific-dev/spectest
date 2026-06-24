# spectest

This repository hosts only the prebuilt `spectest` CLI binaries published from
the (private) source repository.

## Install

Download and install the latest release with `curl` (resolves the newest
version automatically and drops `spectest` on your `PATH`):

**macOS (Apple Silicon)**

```bash
VER=$(curl -fsSL https://api.github.com/repos/specific-dev/spectest/releases/latest | grep -m1 '"tag_name"' | cut -d'"' -f4)
curl -fsSL "https://github.com/specific-dev/spectest/releases/download/${VER}/spectest-${VER#v}-aarch64-apple-darwin.tar.gz" | tar -xz
chmod +x spectest && sudo mv spectest /usr/local/bin/
spectest --help
```

**Linux (x86_64)**

```bash
VER=$(curl -fsSL https://api.github.com/repos/specific-dev/spectest/releases/latest | grep -m1 '"tag_name"' | cut -d'"' -f4)
curl -fsSL "https://github.com/specific-dev/spectest/releases/download/${VER}/spectest-${VER#v}-x86_64-unknown-linux-musl.tar.gz" | tar -xz
chmod +x spectest && sudo mv spectest /usr/local/bin/
spectest --help
```

> **macOS note:** download with `curl` (as above), not your browser. Browser
> downloads get a quarantine flag, so Gatekeeper blocks the unsigned binary
> with *"Apple could not verify 'spectest' is free of malware."* `curl` does
> not set that flag, so the binary runs straight away. If you already
> downloaded it in a browser, clear the flag with
> `xattr -d com.apple.quarantine ./spectest`.

### Manual download

Alternatively, grab the tarball for your platform from the
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
