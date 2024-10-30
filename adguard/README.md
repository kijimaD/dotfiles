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

### 配布DNSサーバ

ルーターがDHCPで配布するDNSサーバーの設定を変える方法。

ルーター管理画面のDHCPサーバー設定 → プライマリDNS に、起動しているDNSサーバのIPアドレスを設定する。稼働させているサーバのIPアドレスは必ず固定しておく。

## 設定を変更する場合

Webコンソールの変更を設定ファイルに変更する場合、あらかじめファイルの権限をrootにしておく必要がある．

```shell
$ sudo chown -R root:root .
```

変更が終わったらユーザの権限に戻してコミットする。

```shell
$ sudo chown -R $USER:$USER .
```

## DNSサーバが使われていないときに確かめること

設定を変更したが何らかの理由でDNSサーバが使われていないとき、端末のネットワークをオンオフして、DHCPから貰うDNSサーバ先を更新する。キャッシュを保持していることがある。
