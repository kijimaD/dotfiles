# 最新の1プロセスを除いて、古いpolybarプロセスを削除する。cronで実行する

COUNT=$(ps aux | grep polybar | grep -v grep | wc -l) && sleep 0.1;

# プロセス数が2000より大きいときのみ削除実行
if [ $COUNT -gt 2000 ]; then
    # 最新の1つを除外して削除
    ps aux | grep polybar | grep -v grep | sed -e '$d'| awk '{ print "kill -9", $2 }' | sh
fi
