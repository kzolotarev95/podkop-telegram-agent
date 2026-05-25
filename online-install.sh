#!/bin/sh
# REPO_ROOT_INSTALL_V14_SPEED_BOT_SAFE_V11016
# podkop-telegram-agent one-link installer/updater from repository root.
# Uses full overlay archive from GitHub repository root, no Releases.
# Usage:
#   wget -O- https://raw.githubusercontent.com/kzolotarev95/podkop-telegram-agent/main/install.sh | ash -s -- --yes

REPO="${PODKOP_TG_REPO:-kzolotarev95/podkop-telegram-agent}"
BRANCH="${PODKOP_TG_BRANCH:-main}"
ASSET="${PODKOP_TG_ASSET:-podkop-telegram-agent-github-release.tar.gz}"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/${ASSET}"
TS="$(date +%s 2>/dev/null || echo 0)"
URL="${PODKOP_TG_URL:-${BASE_URL}?t=${TS}}"
WORKDIR="${PODKOP_TG_WORKDIR:-/tmp/podkop-telegram-agent-online}"
ARCHIVE="/tmp/${ASSET}"
PKGDIR="/tmp/podkop-telegram-agent"

log() { printf '%s
' "$*"; }
fail() { printf 'ERROR: %s
' "$*" >&2; exit 1; }
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

log "podkop-telegram-agent installer"
log "Marker: REPO_ROOT_INSTALL_V14_SPEED_BOT_SAFE_V11016"
log "Mode: GitHub repository root, full overlay archive, no Releases"
log "Archive URL: $BASE_URL"

download "$URL" "$ARCHIVE" || fail "download failed. Check internet/DNS/GitHub/raw.githubusercontent.com access."
[ -s "$ARCHIVE" ] || fail "downloaded archive is empty: $ARCHIVE"

tar -tzf "$ARCHIVE" >/tmp/podkop_tg_archive_list.$$ 2>/tmp/podkop_tg_archive_err.$$ || {
    cat /tmp/podkop_tg_archive_err.$$ >&2 2>/dev/null || true
    rm -f /tmp/podkop_tg_archive_list.$$ /tmp/podkop_tg_archive_err.$$
    fail "cannot list archive $ARCHIVE"
}
grep -Eq '(^|/)files/usr/bin/podkop-telegram-agent$' /tmp/podkop_tg_archive_list.$$ || fail "bad archive: files/usr/bin/podkop-telegram-agent missing"
grep -Eq '(^|/)files/etc/init.d/podkop-telegram-agent$' /tmp/podkop_tg_archive_list.$$ || fail "bad archive: files/etc/init.d/podkop-telegram-agent missing"
grep -Eq '(^|/)files/etc/hotplug.d/iface/99-podkop-tg-speed$' /tmp/podkop_tg_archive_list.$$ || log "WARN: speed hotplug hook missing in archive"
grep -Eq '(^|/)files/www/luci-static/resources/view/podkop-tg/settings.js$' /tmp/podkop_tg_archive_list.$$ || fail "bad archive: LuCI settings.js missing"
grep -Eq '(^|/)install.sh$' /tmp/podkop_tg_archive_list.$$ || fail "bad archive: install.sh missing"
rm -f /tmp/podkop_tg_archive_list.$$ /tmp/podkop_tg_archive_err.$$

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
[ -f files/usr/bin/podkop-telegram-agent ] || fail "package is incomplete: files/usr/bin/podkop-telegram-agent not found"
[ -f files/etc/init.d/podkop-telegram-agent ] || fail "package is incomplete: files/etc/init.d/podkop-telegram-agent not found"
[ -f files/www/luci-static/resources/view/podkop-tg/settings.js ] || fail "package is incomplete: LuCI settings.js not found"

log "Running installer..."
ash install.sh "$@"
