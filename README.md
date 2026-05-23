# Podkop Telegram Agent

<p align="center">
  <b>Telegram-модуль для управления Podkop / OpenWrt</b>
</p>

<p align="center">
  Управление роутером, Podkop, sing-box, логами, отчётами, backup, родительским контролем и VLESS/URLTest прямо из Telegram.
</p>

<p align="center">
  <img src="images/banner.png" alt="Podkop Telegram Agent Banner" width="100%">
</p>

---

## О проекте

**Podkop Telegram Agent** — это Telegram-бот для OpenWrt, который работает отдельной службой на роутере и управляется через UCI-конфиг:

```sh
/etc/config/podkop_tg
```

Бот создан для удобного управления **Podkop**, **sing-box** и самим роутером прямо из Telegram.

Он не редактирует напрямую:

```sh
/etc/sing-box/config.json
```

и не ломает системные правила Podkop. Все настройки выполняются через OpenWrt/UCI и отдельные безопасные firewall-таблицы.

---

## Возможности

### Управление Podkop

- просмотр статуса Podkop;
- просмотр статуса sing-box;
- перезапуск Podkop;
- обновление Podkop через официальный install.sh;
- проверка работы Podkop;
- просмотр Podkop runtime;
- диагностика nft / DNS / routing / FakeIP;
- безопасное обновление proxy-ссылки через UCI.

---

### Статус и отчёты

Бот умеет показывать расширенный отчёт по роутеру:

- модель устройства;
- версия OpenWrt;
- kernel;
- uptime;
- load average;
- температура;
- RAM;
- SWAP;
- Flash /overlay;
- внешний IP;
- ping;
- WAN-трафик;
- Wi-Fi интерфейсы;
- DHCP-клиенты;
- Wi-Fi-клиенты;
- версии Podkop и sing-box;
- текущая версия бота.

---

### Логи из Telegram

Можно смотреть логи прямо из Telegram:

- общие логи;
- ошибки;
- Podkop;
- sing-box;
- DNS;
- nft;
- runtime.

Примеры команд:

```text
/logs WBR3000UAX
/logs WBR3000UAX all 200
/logs WBR3000UAX errors 100
/logs WBR3000UAX podkop 100
/logs WBR3000UAX singbox 100
```

---

### Родительский контроль

Добавлен раздел:

```text
👨‍👩‍👧 Родительский Контроль
```

Бот видит статические DHCP-устройства роутера и показывает:

- имя хоста;
- MAC-адрес;
- IPv4-адрес;
- online/offline статус;
- активные блокировки.

Для каждого устройства создаётся отдельная карточка с кнопками.

Можно:

- заблокировать устройство вручную;
- разблокировать устройство;
- задать ограничение по времени;
- использовать быстрые шаблоны;
- смотреть активные блокировки;
- удалять правила.

Примеры:

```text
/access WBR3000UAX
/accessblocked WBR3000UAX
/accessblock WBR3000UAX 192.168.2.146
/accessunblock WBR3000UAX 192.168.2.146
/accessset WBR3000UAX 192.168.2.146 14:00-20:00 mon-fri
/accessdel WBR3000UAX 192.168.2.146
/accessapply WBR3000UAX
```

Блокировка работает даже если трафик устройства идёт через Podkop / sing-box.

Для блокировки используются отдельные таблицы:

```text
inet podkop_tg_access
bridge podkop_tg_access_bridge
netdev podkop_tg_access_ingress
```

PodkopTable и sing-box config не изменяются.

---

### URLTest / VLESS

Добавлен раздел:

```text
🔗 URLTest / VLESS
```

Бот умеет работать с proxy-ссылками из Podkop:

- `urltest_proxy_links`;
- `selector_proxy_links`;
- `proxy_string`.

Можно:

- вывести все VLESS/proxy-ссылки;
- увидеть имя сервера из `#tag`;
- увидеть host и port;
- проверить TCP-доступность сервера;
- добавить новую ссылку;
- удалить ссылку;
- применить выбранную ссылку;
- вернуть секцию обратно в URLTest.

Примеры:

```text
/urltest WBR3000UAX
/urlping WBR3000UAX
/urluse WBR3000UAX 1
/urladd WBR3000UAX main vless://...
/urldel WBR3000UAX 1
/urlteston WBR3000UAX main
/urlapply WBR3000UAX
```

---

### Backup OpenWrt

Бот умеет создавать backup OpenWrt через:

```sh
sysupgrade -b
```

и отправлять архив в Telegram.

Команда:

```text
/backup WBR3000UAX
```

---

### Аварийные уведомления

Бот умеет присылать уведомления:

- WAN DOWN / WAN UP;
- Internet DOWN / Internet UP;
- Podkop DOWN / Podkop UP;
- sing-box DOWN / sing-box UP;
- reboot роутера;
- быстрый restart Podkop.

Если Telegram временно недоступен, уведомление сохраняется в очередь и отправляется позже.

---

### Multi-router режим

Бот поддерживает несколько роутеров.

Один роутер может быть главным:

```text
bot_mode='panel'
```

Остальные могут быть ведомыми:

```text
bot_mode='worker'
```

В Telegram можно выбрать нужный роутер кнопками и выполнять команды именно на нём.

Пример:

```sh
uci set podkop_tg.main.bot_mode='panel'
uci set podkop_tg.main.router_name='WBR3000UAX'
uci set podkop_tg.main.router_list='WBR3000UAX AX3000T NanoPiR3S'
uci commit podkop_tg
/etc/init.d/podkop-telegram-agent restart
```

---

### Обновление самого бота

Добавлена кнопка:

```text
🤖 Обновить Бота
```

Бот может обновлять сам себя из Telegram.

Команда обновления:

```sh
wget -O- https://raw.githubusercontent.com/kzolotarev95/podkop-telegram-agent/main/install.sh | ash -s -- --yes
```

После обновления бот присылает результат и лог установки.

Лог сохраняется тут:

```sh
/tmp/podkop_tg_bot_update.log
```

---

## Главное меню Telegram

В боте доступны кнопки:

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

Установка / обновление:

```sh
wget -O- https://raw.githubusercontent.com/kzolotarev95/podkop-telegram-agent/main/install.sh | ash -s -- --yes
```

---

### OpenWrt 25

OpenWrt 25 использует `apk` вместо `opkg`.

```sh
apk update
apk add curl jq ca-bundle tar gzip rpcd-mod-file iwinfo
```

Установка / обновление:

```sh
wget -O- https://raw.githubusercontent.com/kzolotarev95/podkop-telegram-agent/main/install.sh | ash -s -- --yes
```

---

## Первичная настройка

После установки нужно прописать токен Telegram-бота и chat_id.

```sh
uci set podkop_tg.main.enabled='1'
uci set podkop_tg.main.token='ТВОЙ_TELEGRAM_BOT_TOKEN'
uci set podkop_tg.main.chat_id='ТВОЙ_TELEGRAM_USER_ID'
uci set podkop_tg.main.router_name='WBR3000UAX'
uci set podkop_tg.main.podkop_section='main'
uci commit podkop_tg

/etc/init.d/podkop-telegram-agent enable
/etc/init.d/podkop-telegram-agent restart
```

---

## Где взять Telegram token

1. Открой Telegram.
2. Найди бота:

```text
@BotFather
```

3. Отправь:

```text
/newbot
```

4. Введи имя бота.
5. Введи username бота, он должен заканчиваться на `bot`.
6. BotFather выдаст token.

Пример token:

```text
1234567890:AAExampleTokenExampleToken
```

Его нужно прописать в OpenWrt:

```sh
uci set podkop_tg.main.token='ТВОЙ_TOKEN'
uci commit podkop_tg
/etc/init.d/podkop-telegram-agent restart
```

---

## Как узнать chat_id

Напиши своему боту любое сообщение, потом на роутере выполни:

```sh
TOKEN="$(uci -q get podkop_tg.main.token)"
wget -qO- "https://api.telegram.org/bot${TOKEN}/getUpdates"
```

В ответе найди:

```text
"chat":{"id":123456789}
```

Этот ID нужно прописать:

```sh
uci set podkop_tg.main.chat_id='123456789'
uci commit podkop_tg
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

Проверка:

```sh
uci get podkop_tg.main.device_control
```

Должно быть:

```text
1
```

---

## Проверка после установки

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

Полное удаление бота:

```sh
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

Проверка удаления:

```sh
ls -la /etc/init.d/podkop-telegram-agent* 2>/dev/null
ls -la /usr/bin/podkop-telegram-agent* 2>/dev/null
ls -la /etc/config/podkop_tg* 2>/dev/null

logread -e podkop-telegram-agent | tail -n 80
```

---

## Структура проекта

```text
podkop-telegram-agent/
├── install.sh
├── online-install.sh
├── podkop-telegram-agent-github-release.tar.gz
├── podkop-telegram-agent-github-release.zip
├── podkop-telegram-agent-github-release.sha256
├── files/
│   ├── usr/bin/podkop-telegram-agent
│   ├── usr/bin/podkop-telegram-agent-logread
│   ├── etc/init.d/podkop-telegram-agent
│   ├── etc/config/podkop_tg
│   ├── etc/podkop-telegram-agent/header.jpg
│   ├── usr/share/luci/menu.d/luci-app-podkop-tg.json
│   ├── usr/share/rpcd/acl.d/luci-app-podkop-tg.json
│   └── www/luci-static/resources/view/podkop-tg/settings.js
└── README.md
```

---

## Совместимость

Проверялось на:

```text
OpenWrt 24.x
OpenWrt 25.x
Podkop
sing-box
firewall4 / nftables
apk / opkg
```

---

## Важно

- Для родительского контроля лучше использовать статические DHCP-адреса.
- Для OpenWrt 25 используется `apk`, для OpenWrt 24 — `opkg`.
- Бот не редактирует напрямую `sing-box config`.
- Бот не изменяет `PodkopTable`.
- Для блокировок используются отдельные таблицы `podkop_tg_access`.
- После обновления рекомендуется перезапустить службу.

```sh
/etc/init.d/podkop-telegram-agent restart
```

---

## Автор

Модуль сделан для удобного управления Podkop/OpenWrt через Telegram.

Спасибо большое за данный модуль начинающему скриптеру **by zks95** ❤️

Telegram: `@zks95`

GitHub: `https://github.com/kzolotarev95/podkop-telegram-agent`
