#!/bin/bash
set -u

########################
# 設定ファイルをデプロイ + 起動する
# squidはほかのポートにアクセスするため管理者権限で実行する必要がある
# 例) $ sudo MODE=priv ./launch.sh
########################

cd `dirname $0`

aclfile="blacklist_$MODE"

# バリデーション ================
if [ ! -e $aclfile ]; then
    echo "エラー: $aclfileが存在しないため中断した"
    exit 1
fi

if [ $EUID -ne 0 ]; then
    echo "This script must be run as root!"
    exit 1
fi

if ! squid -v >/dev/null 2>&1; then
    echo "need squid command!"
fi

# 配置 ================
cp -R conf.d squid.conf /etc/squid/
cp $aclfile /etc/squid/blacklist

# 起動 ================
killall -q squid
squid --foreground &

echo "squid launched..."
