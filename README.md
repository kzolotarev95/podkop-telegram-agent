wget -O- https://raw.githubusercontent.com/kzolotarev95/podkop-telegram-agent/main/online-install.sh | grep -E "REPO_RAW_INSTALL_V3|releases/latest"


wget -O- https://raw.githubusercontent.com/kzolotarev95/podkop-telegram-agent/main/online-install.sh | ash -s -- --yes

/etc/init.d/podkop-telegram-agent restart
/etc/init.d/podkop-telegram-agent status
logread -e podkop-telegram-agent | tail -n 160
logread -e podkop | tail -n 80
logread -e sing-box | tail -n 80

https://raw.githubusercontent.com/kzolotarev95/podkop-telegram-agent/main/podkop-telegram-agent-github-release.tar.gz

wget -O /tmp/test.tar.gz https://raw.githubusercontent.com/kzolotarev95/podkop-telegram-agent/main/podkop-telegram-agent-github-release.tar.gz
ls -lh /tmp/test.tar.gz
