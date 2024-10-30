## 起動

まずポート53番を開けないと起動できない。

`/etc/systemd/resolved.conf`
```
DNSStubListener=no
```

```shell
$ sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
$ sudo systemctl restart systemd-resolved
```

起動する。

```shell
$ docker compose up -d
```

## 2つの方法

接続先DNSサーバをadguardにすることで、フィルタリングする。

### クライアント

個々の端末のDNSアドレスを変える方法。

`/etc/resolv.conf`
```
# adguardを起動しているマシンのIPアドレス
nameserver 127.0.0.1
```

### ルーター

ルーターがDHCPで配布するDNSサーバーの設定を変える方法。

ルーター管理画面のDHCPサーバー → プライマリDNS に起動しているサーバのIPアドレスを設定する。
