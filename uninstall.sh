#!/bin/sh
# REPO_ROOT_UNINSTALL_V1
# podkop-telegram-agent full uninstaller for OpenWrt 24/25.
# Usage:
#   wget -O- https://raw.githubusercontent.com/kzolotarev95/podkop-telegram-agent/main/uninstall.sh | ash -s -- --yes

set +e

YES=0
KEEP_CONFIG=0

for arg in "$@"; do
    case "$arg" in
        --yes|-y) YES=1 ;;
        --keep-config) KEEP_CONFIG=1 ;;
        --help|-h)
            cat <<'HELP'
podkop-telegram-agent uninstaller

Options:
  --yes          run uninstall without prompt
  --keep-config  keep /etc/config/podkop_tg and /etc/podkop-telegram-agent

Example:
  wget -O- https://raw.githubusercontent.com/kzolotarev95/podkop-telegram-agent/main/uninstall.sh | ash -s -- --yes
HELP
            exit 0
            ;;
    esac
done

log() { printf '%s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

if [ "$YES" != "1" ]; then
    log "ERROR: uninstall is destructive. Run with --yes"
    log "Example:"
    log "wget -O- https://raw.githubusercontent.com/kzolotarev95/podkop-telegram-agent/main/uninstall.sh | ash -s -- --yes"
    exit 1
fi

log "podkop-telegram-agent uninstaller"
log "Marker: REPO_ROOT_UNINSTALL_V1"

log "Stopping service..."
/etc/init.d/podkop-telegram-agent stop 2>/dev/null
/etc/init.d/podkop-telegram-agent disable 2>/dev/null

log "Removing init/service files..."
rm -f /etc/init.d/podkop-telegram-agent
rm -f /etc/init.d/podkop-telegram-agent.backup.*
rm -f /etc/rc.d/*podkop-telegram-agent*

log "Removing binaries..."
rm -f /usr/bin/podkop-telegram-agent
rm -f /usr/bin/podkop-telegram-agent.backup.*
rm -f /usr/bin/podkop-telegram-agent-logread
rm -f /usr/bin/podkop-telegram-agent-logread.backup.*

if [ "$KEEP_CONFIG" = "1" ]; then
    log "Keeping config because --keep-config was used."
else
    log "Removing config and data..."
    rm -f /etc/config/podkop_tg
    rm -f /etc/config/podkop_tg.backup.*
    rm -rf /etc/podkop-telegram-agent
fi

log "Removing LuCI files..."
rm -f /usr/share/luci/menu.d/luci-app-podkop-tg.json
rm -f /usr/share/luci/menu.d/luci-app-podkop-tg.json.backup.*
rm -f /usr/share/rpcd/acl.d/luci-app-podkop-tg.json
rm -f /usr/share/rpcd/acl.d/luci-app-podkop-tg.json.backup.*
rm -rf /www/luci-static/resources/view/podkop-tg

log "Removing nft firewall tables..."
if have nft; then
    nft delete table inet podkop_tg_access 2>/dev/null
    nft delete table bridge podkop_tg_access_bridge 2>/dev/null
    nft delete table netdev podkop_tg_access_ingress 2>/dev/null
fi

log "Removing iptables fallback chains..."
if have iptables; then
    for tbl in raw mangle filter; do
        for chain in PODKOP_TG_ACCESS_RAW PODKOP_TG_ACCESS_PRE PODKOP_TG_ACCESS PODKOP_TG_ACCESS_IN; do
            for hook in PREROUTING INPUT FORWARD OUTPUT; do
                while iptables -t "$tbl" -D "$hook" -j "$chain" >/dev/null 2>&1; do :; done
            done
            iptables -t "$tbl" -F "$chain" >/dev/null 2>&1
            iptables -t "$tbl" -X "$chain" >/dev/null 2>&1
        done
    done
fi

log "Cleaning temporary files and LuCI cache..."
rm -rf /tmp/podkop_tg_* \
       /tmp/podkop-telegram-agent \
       /tmp/podkop-telegram-agent-online \
       /tmp/luci-indexcache \
       /tmp/luci-modulecache \
       /tmp/luci-*cache

log "Restarting LuCI services..."
/etc/init.d/rpcd restart 2>/dev/null
/etc/init.d/uhttpd restart 2>/dev/null

log "Done. podkop-telegram-agent removed."
log "Check:"
log "  ls -la /etc/init.d/podkop-telegram-agent* /usr/bin/podkop-telegram-agent* /etc/config/podkop_tg* 2>/dev/null"
log "  logread -e podkop-telegram-agent | tail -n 80"
