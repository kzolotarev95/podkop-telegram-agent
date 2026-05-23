# Podkop Telegram Agent

<p align="center">
  <b>Telegram-бот для управления Podkop / OpenWrt</b>
</p>

<p align="center">
  Статус, отчёты, логи, backup, родительский контроль, URLTest/VLESS и обновление Podkop прямо из Telegram.
</p>

<p align="center">
  <img src="images/banner.png" alt="Podkop Telegram Agent" width="100%">
</p>

---

## Описание

**Podkop Telegram Agent** — это Telegram-модуль для OpenWrt.

Агент работает отдельной службой и управляется через UCI-конфиг:

```sh
/etc/config/podkop_tg
```

Проект создан для удобного управления роутером, Podkop и sing-box прямо из Telegram.

Бот не редактирует напрямую `sing-box config` и не изменяет `PodkopTable`.

---

## Основные функции

### Управление Podkop

- статус Podkop и sing-box;
- перезапуск Podkop;
- обновление Podkop из Telegram;
- глобальная диагностика;
- проверка DNS, nft, routing, FakeIP;
- работа с proxy-ссылками через UCI.

### Статус и отчёты

Бот показывает:

- модель роутера;
- версию OpenWrt;
- kernel;
- uptime;
- температуру;
- RAM / SWAP / Flash;
- WAN IP;
- ping;
- Wi-Fi;
- клиентов;
- версии Podkop, sing-box и самого бота.

### Логи из Telegram

Доступен просмотр логов:

```text
/logs ROUTER
/logs ROUTER errors
/logs ROUTER podkop
/logs ROUTER singbox
/logs ROUTER nft
/logs ROUTER dns
```

### Родительский контроль

Раздел:

```text
👨‍👩‍👧 Родительский Контроль
```

Возможности:

- список статических DHCP-устройств;
- отображение имени, MAC и IPv4;
- ручная блокировка устройства;
- разблокировка устройства;
- ограничение по расписанию;
- список активных блокировок;
- блокировка трафика даже через Podkop / sing-box.

Пример:

```text
/accessblock WBR3000UAX 192.168.2.146
/accessunblock WBR3000UAX 192.168.2.146
/accessset WBR3000UAX 192.168.2.146 14:00-20:00 mon-fri
```

### URLTest / VLESS

Раздел:

```text
🔗 URLTest / VLESS
```

Возможности:

- вывод VLESS/proxy-ссылок из Podkop;
- отображение имени сервера, host и port;
- проверка доступности сервера;
- добавление новой ссылки;
- удаление ссылки;
- применение выбранной ссылки;
- возврат секции в URLTest.

Пример:

```text
/urltest WBR3000UAX
/urlping WBR3000UAX
/urluse WBR3000UAX 1
/urladd WBR3000UAX main vless://...
```

### Backup OpenWrt

Бот умеет создавать backup роутера и отправлять архив в Telegram.

```text
/backup WBR3000UAX
```

### Уведомления

Бот может присылать уведомления:

- WAN DOWN / UP;
- Internet DOWN / UP;
- Podkop DOWN / UP;
- sing-box DOWN / UP;
- reboot роутера;
- restart Podkop.

### Multi-router

Поддерживается управление несколькими роутерами.

Один роутер может быть `panel`, остальные — `worker`.

```sh
uci set podkop_tg.main.bot_mode='panel'
uci set podkop_tg.main.router_name='WBR3000UAX'
uci set podkop_tg.main.router_list='WBR3000UAX AX3000T NanoPiR3S'
uci commit podkop_tg
/etc/init.d/podkop-telegram-agent restart
```

---

## Главное меню

```text
🟢 Статус
🔄 Рестарт
📄 Посмотреть логи
🌐 Получить глобальную проверку
📊 Отчёт
📦 Backup OpenWrt
👨‍👩‍👧 Родительский Контроль
🔗 URLTest / VLESS
⬆️ Обновить Podkop
🤖 Обновить Бота
❓ Помощь
```

---

## Установка

### OpenWrt 24

```sh
opkg update
opkg install curl jq ca-bundle unzip tar gzip rpcd-mod-file iwinfo
```

### OpenWrt 25

```sh
apk update
apk add curl jq ca-bundle tar gzip rpcd-mod-file iwinfo
```

### Установить / обновить

```sh
wget -O- https://raw.githubusercontent.com/kzolotarev95/podkop-telegram-agent/main/install.sh | ash -s -- --yes
```

---

## Первичная настройка

```sh
uci set podkop_tg.main.enabled='1'
uci set podkop_tg.main.token='TELEGRAM_BOT_TOKEN'
uci set podkop_tg.main.chat_id='TELEGRAM_USER_ID'
uci set podkop_tg.main.router_name='WBR3000UAX'
uci set podkop_tg.main.podkop_section='main'
uci commit podkop_tg

/etc/init.d/podkop-telegram-agent enable
/etc/init.d/podkop-telegram-agent restart
```

---

## Включить родительский контроль

```sh
uci set podkop_tg.main.device_control='1'
uci commit podkop_tg

rm -f /tmp/podkop_tg_access_devices.cache
rm -f /tmp/podkop_tg_access_last

/etc/init.d/podkop-telegram-agent restart
```

---

## Проверка

```sh
/etc/init.d/podkop-telegram-agent status
uci show podkop_tg | sed "s/token='[^']*'/token='***'/"
```

Логи:

```sh
logread -e podkop-telegram-agent | tail -n 160
logread -e podkop | tail -n 80
logread -e sing-box | tail -n 80
```

---

## Удаление

```sh
/etc/init.d/podkop-telegram-agent stop 2>/dev/null
/etc/init.d/podkop-telegram-agent disable 2>/dev/null

rm -f /etc/init.d/podkop-telegram-agent
rm -f /etc/rc.d/*podkop-telegram-agent*

rm -f /usr/bin/podkop-telegram-agent
rm -f /usr/bin/podkop-telegram-agent-logread

rm -f /etc/config/podkop_tg
rm -rf /etc/podkop-telegram-agent

rm -f /usr/share/luci/menu.d/luci-app-podkop-tg.json
rm -f /usr/share/rpcd/acl.d/luci-app-podkop-tg.json
rm -rf /www/luci-static/resources/view/podkop-tg

nft delete table inet podkop_tg_access 2>/dev/null
nft delete table bridge podkop_tg_access_bridge 2>/dev/null
nft delete table netdev podkop_tg_access_ingress 2>/dev/null

rm -rf /tmp/podkop_tg_* /tmp/luci-indexcache /tmp/luci-modulecache /tmp/luci-*cache

/etc/init.d/rpcd restart 2>/dev/null
/etc/init.d/uhttpd restart 2>/dev/null
```

---

## Совместимость

```text
OpenWrt 24.x
OpenWrt 25.x
Podkop
sing-box
firewall4 / nftables
opkg / apk
```

---

## Автор

Спасибо большое за данный модуль начинающему скриптеру **by zks95** ❤️

GitHub: `https://github.com/kzolotarev95/podkop-telegram-agent`
