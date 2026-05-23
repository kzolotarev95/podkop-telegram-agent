#!/bin/sh
# REPO_RAW_INSTALL_V3
# podkop-telegram-agent one-link installer/updater for OpenWrt 24/25.
# Downloads archive from repository root via raw.githubusercontent.com.
# Does NOT use GitHub Releases.
# Usage:
#   wget -O- https://raw.githubusercontent.com/kzolotarev95/podkop-telegram-agent/main/online-install.sh | ash -s -- --yes

REPO="${PODKOP_TG_REPO:-kzolotarev95/podkop-telegram-agent}"
BRANCH="${PODKOP_TG_BRANCH:-main}"
ASSET="${PODKOP_TG_ASSET:-podkop-telegram-agent-github-release.tar.gz}"
URL="${PODKOP_TG_URL:-https://raw.githubusercontent.com/${REPO}/${BRANCH}/${ASSET}}"
WORKDIR="${PODKOP_TG_WORKDIR:-/tmp/podkop-telegram-agent-online}"
ARCHIVE="/tmp/${ASSET}"
PKGDIR="/tmp/podkop-telegram-agent"

log() { printf '%s\n' "$*"; }
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

download() {
    local url="$1" out="$2"
    rm -f "$out"
    if have wget; then
        wget -O "$out" "$url" || return 1
        return 0
    fi
    if have curl; then
        curl -L --fail -o "$out" "$url" || return 1
        return 0
    fi
    return 1
}

[ -f /etc/openwrt_release ] || log "WARN: /etc/openwrt_release not found; continuing anyway."
have tar || fail "tar not found"

log "podkop-telegram-agent online installer"
log "Mode: repo-root raw.githubusercontent.com"
log "Marker: REPO_RAW_INSTALL_V3"
log "Archive URL: $URL"

download "$URL" "$ARCHIVE" || fail "download failed. Check internet/DNS/GitHub/raw.githubusercontent.com access."

rm -rf "$WORKDIR" "$PKGDIR"
mkdir -p "$WORKDIR" || fail "cannot create $WORKDIR"

tar -xzf "$ARCHIVE" -C "$WORKDIR" || fail "cannot extract $ARCHIVE"

if [ -d "$WORKDIR/podkop-telegram-agent" ]; then
    mv "$WORKDIR/podkop-telegram-agent" "$PKGDIR" || fail "cannot move package to $PKGDIR"
elif [ -f "$WORKDIR/install.sh" ]; then
    mv "$WORKDIR" "$PKGDIR" || fail "cannot move package to $PKGDIR"
else
    fail "package layout is invalid: install.sh not found"
fi

cd "$PKGDIR" || fail "cannot cd to $PKGDIR"
[ -f install.sh ] || fail "install.sh not found in package"

log "Running installer..."
ash install.sh "$@"
