**Установить / обновить бота одной командой**

`wget -O- https://raw.githubusercontent.com/kzolotarev95/podkop-telegram-agent/main/online-install.sh | ash -s -- --yes`

**Включить родительский контроль**

```
uci set podkop_tg.main.device_control='1'
uci commit podkop_tg
rm -f /tmp/podkop_tg_access_devices.cache
rm -f /tmp/podkop_tg_access_last
/etc/init.d/podkop-telegram-agent restart
```

**Полностью удалить бота**

```
/etc/init.d/podkop-telegram-agent stop 2>/dev/null
/etc/init.d/podkop-telegram-agent disable 2>/dev/null
rm -f /etc/init.d/podkop-telegram-agent
rm -f /etc/init.d/podkop-telegram-agent.backup.*
rm -f /etc/rc.d/*podkop-telegram-agent*
rm -f /usr/bin/podkop-telegram-agent
rm -f /usr/bin/podkop-telegram-agent.backup.*
rm -f /usr/bin/podkop-telegram-agent-logread
rm -f /usr/bin/podkop-telegram-agent-logread.backup.*
rm -f /etc/config/podkop_tg
rm -f /etc/config/podkop_tg.backup.*
rm -rf /etc/podkop-telegram-agent
rm -f /usr/share/luci/menu.d/luci-app-podkop-tg.json
rm -f /usr/share/luci/menu.d/luci-app-podkop-tg.json.backup.*
rm -f /usr/share/rpcd/acl.d/luci-app-podkop-tg.json
rm -f /usr/share/rpcd/acl.d/luci-app-podkop-tg.json.backup.*
rm -rf /www/luci-static/resources/view/podkop-tg
nft delete table inet podkop_tg_access 2>/dev/null
nft delete table bridge podkop_tg_access_bridge 2>/dev/null
nft delete table netdev podkop_tg_access_ingress 2>/dev/null
rm -rf /tmp/podkop_tg_* /tmp/luci-indexcache /tmp/luci-modulecache /tmp/luci-*cache
/etc/init.d/rpcd restart 2>/dev/null
/etc/init.d/uhttpd restart 2>/dev/null
```

**Проверить, что удалилось**

```
ls -la /etc/init.d/podkop-telegram-agent* 2>/dev/null
ls -la /usr/bin/podkop-telegram-agent* 2>/dev/null
ls -la /etc/config/podkop_tg* 2>/dev/null
ls -la /etc/podkop-telegram-agent 2>/dev/null
nft list table inet podkop_tg_access 2>/dev/null
nft list table bridge podkop_tg_access_bridge 2>/dev/null
nft list table netdev podkop_tg_access_ingress 2>/dev/null
logread -e podkop-telegram-agent | tail -n 80
```
