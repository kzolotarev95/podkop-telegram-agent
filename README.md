<img width="2172" height="724" alt="0b31a5f4-f61b-43de-9567-c8fdcf2333f5" src="https://github.com/user-attachments/assets/2e6c8bd0-0319-4265-acb3-4eacad746597" />


## Установка в один клик


```sh
wget -O- https://raw.githubusercontent.com/kzolotarev95/podkop-telegram-agent/main/install.sh | ash -s -- --yes
```

## Удаление одной командой

```sh
wget -O- https://raw.githubusercontent.com/kzolotarev95/podkop-telegram-agent/main/uninstall.sh | ash -s -- --yes
```

<img width="1920" height="3158" alt="mSdqBmGcvZ" src="https://github.com/user-attachments/assets/a66e9324-ed35-4871-a00f-077a9f3cbaee" />




## Возможности

- 🟢 статус роутера, Podkop и sing-box;
- 📊 расширенный отчёт по системе;
- 📄 просмотр логов из Telegram;
- 🌐 глобальная диагностика Podkop;
- 🔄 перезапуск Podkop и reboot роутера;
- 📦 backup OpenWrt в Telegram;
- 👨‍👩‍👧 родительский контроль устройств;
- 🔗 управление URLTest / VLESS ссылками;
- ⬆️ обновление Podkop;
- 🤖 обновление самого бота;
- 🖥️ LuCI-страница настроек;
- 🔀 multi-router режим panel / worker.

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

## Родительский контроль

Бот видит статические DHCP-устройства:

```text
Имя хоста
MAC-адрес
IPv4-адрес
online / offline
```

Можно:

```text
заблокировать устройство
разблокировать устройство
задать расписание
посмотреть активные блокировки
```

Блокировка работает даже если трафик идёт через **Podkop / sing-box**.

---

## URLTest / VLESS

Бот умеет работать с proxy-ссылками Podkop:

```text
urltest_proxy_links
selector_proxy_links
proxy_string
```

Можно:

```text
посмотреть все ссылки
проверить доступность сервера
добавить VLESS
удалить ссылку
применить выбранную ссылку
вернуть секцию в URLTest
```


## Структура проекта

```text
podkop-telegram-agent/
├── install.sh
├── online-install.sh
├── podkop-telegram-agent-github-release.tar.gz
├── podkop-telegram-agent-github-release.zip
├── podkop-telegram-agent-github-release.sha256
├── README.md
└── files/
    ├── usr/
    │   └── bin/
    │       ├── podkop-telegram-agent
    │       └── podkop-telegram-agent-logread
    ├── etc/
    │   ├── init.d/
    │   │   └── podkop-telegram-agent
    │   ├── config/
    │   │   └── podkop_tg
    │   └── podkop-telegram-agent/
    │       └── header.jpg
    ├── usr/share/
    │   ├── luci/menu.d/
    │   │   └── luci-app-podkop-tg.json
    │   └── rpcd/acl.d/
    │       └── luci-app-podkop-tg.json
    └── www/luci-static/resources/view/podkop-tg/
        └── settings.js
```


## Удаление

```sh
/etc/init.d/podkop-telegram-agent stop 2>/dev/null
/etc/init.d/podkop-telegram-agent disable 2>/dev/null

rm -f /etc/init.d/podkop-telegram-agent
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
