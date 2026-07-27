#!/bin/sh
# Install the spectest CLI.
#
#   curl -fsSL https://raw.githubusercontent.com/specific-dev/spectest/main/install.sh | sh
#
# Environment:
#   SPECTEST_VERSION      release to install, e.g. v0.2.36 (default: latest)
#   SPECTEST_INSTALL_DIR  where to put the binary (default: see pick_install_dir)
#
# POSIX sh on purpose — this runs under whatever /bin/sh the machine has
# (dash, busybox ash, bash in POSIX mode), so: no arrays, no [[ ]], no local.
set -eu

REPO="specific-dev/spectest"
BIN="spectest"

say() { printf '%s\n' "$*"; }
err() { printf 'error: %s\n' "$*" >&2; }
die() { err "$*"; exit 1; }

need() {
    command -v "$1" >/dev/null 2>&1 || die "this installer needs \`$1\` on PATH"
}

# Fetch a URL to stdout. curl or wget, whichever exists — the documented
# invocation pipes curl, but someone may well have used wget to get here.
fetch() {
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$1"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- "$1"
    else
        die "this installer needs either \`curl\` or \`wget\` on PATH"
    fi
}

# Map the machine to a release asset suffix. We publish two targets; anything
# else gets a clear refusal rather than a 404 halfway through a download.
detect_target() {
    os=$(uname -s)
    arch=$(uname -m)
    case "$os/$arch" in
        Linux/x86_64|Linux/amd64)      printf 'x86_64-unknown-linux-musl' ;;
        Darwin/arm64|Darwin/aarch64)   printf 'aarch64-apple-darwin' ;;
        Darwin/x86_64)
            die "spectest publishes an Apple Silicon build only; this is an Intel Mac.
       Run it under Rosetta or use a Linux x86_64 machine." ;;
        *)
            die "no spectest build for $os/$arch.
       Supported: Linux x86_64, macOS Apple Silicon." ;;
    esac
}

# Newest published release tag, read from the releases API. No jq: the field
# is on its own line in GitHub's JSON, so grep+cut is enough and keeps the
# dependency list at curl-or-wget.
latest_version() {
    v=$(fetch "https://api.github.com/repos/$REPO/releases/latest" \
        | grep -m1 '"tag_name"' | cut -d'"' -f4)
    [ -n "$v" ] || die "could not resolve the latest release (GitHub API unreachable, or rate limited)"
    printf '%s' "$v"
}

# Where to put the binary. Preference order, and deliberately no `sudo`: a
# script piped from the internet should not be asking for your password, and
# a per-user install needs no privileges at all.
pick_install_dir() {
    if [ -n "${SPECTEST_INSTALL_DIR:-}" ]; then
        printf '%s' "$SPECTEST_INSTALL_DIR"
    elif [ -w /usr/local/bin ] 2>/dev/null; then
        printf '/usr/local/bin'
    else
        printf '%s/.local/bin' "$HOME"
    fi
}

# Is `dir` on PATH? Used only to decide whether to print the hint.
on_path() {
    case ":${PATH}:" in
        *":$1:"*) return 0 ;;
        *) return 1 ;;
    esac
}

main() {
    need tar
    need mktemp

    target=$(detect_target)
    version="${SPECTEST_VERSION:-$(latest_version)}"
    # Tags are vX.Y.Z; asset names carry the bare version.
    bare="${version#v}"
    dir=$(pick_install_dir)

    base="https://github.com/$REPO/releases/download/$version"
    tarball="$BIN-$bare-$target.tar.gz"

    say "installing $BIN $version ($target) to $dir"

    tmp=$(mktemp -d)
    # Clean up on any exit. HUP/PIPE matter as well as the obvious ones: if the
    # caller pipes our output somewhere that goes away (`… | sh | head`), the
    # shell dies on SIGPIPE and would otherwise leave the download behind.
    trap 'rm -rf "$tmp"' EXIT HUP INT PIPE TERM

    fetch "$base/$tarball" > "$tmp/$tarball" \
        || die "download failed: $base/$tarball"
    [ -s "$tmp/$tarball" ] || die "downloaded an empty file from $base/$tarball"

    tar -xzf "$tmp/$tarball" -C "$tmp" || die "could not extract $tarball"
    [ -f "$tmp/$BIN" ] || die "archive did not contain a \`$BIN\` binary"
    chmod +x "$tmp/$BIN"

    mkdir -p "$dir" || die "could not create $dir"
    # Move into place via the destination directory so the rename is atomic
    # (same filesystem) — and so replacing a *running* binary works, since the
    # old inode stays alive for anyone using it.
    if ! mv -f "$tmp/$BIN" "$dir/$BIN" 2>/dev/null; then
        die "could not write to $dir.
       Re-run with SPECTEST_INSTALL_DIR set to somewhere writable, e.g.
         curl -fsSL https://raw.githubusercontent.com/$REPO/main/install.sh | SPECTEST_INSTALL_DIR=\$HOME/.local/bin sh"
    fi

    say "installed $dir/$BIN"

    # Liveness check: catches a wrong-architecture download ("Exec format
    # error") immediately rather than at first use. A warning, not a failure —
    # the binary is on disk either way and the user can investigate.
    if ! "$dir/$BIN" --help >/dev/null 2>&1; then
        say "warning: $dir/$BIN did not run — wrong architecture, or missing permissions"
    fi

    if ! on_path "$dir"; then
        say ""
        say "$dir is not on your PATH. Add it:"
        say "  export PATH=\"$dir:\$PATH\""
    fi

    say ""
    say "Next: spectest docs    # the guide to writing environments and tests"
}

# Everything lives in main() and it is called on the last line, so a
# truncated download (the real hazard of `curl … | sh`) can't execute a
# half-written script — sh reads the whole function definition before running
# anything.
main "$@"
