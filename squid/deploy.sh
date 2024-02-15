#!/bin/bash
set -ux

########################
# 設定ファイルをデプロイ + 起動する
# squidはほかのポートにアクセスするため管理者権限で実行する必要がある
########################

cd `dirname $0`

if [ $EUID -ne 0 ]; then
    echo "This script must be run as root!"
    exit 1
fi

cp -R conf.d squid.conf blacklist /etc/squid/

killall -q squid

# wait
while pgrep -u $EUID -x squid >/dev/null; do sleep 1; done

squid &

sleep 2
