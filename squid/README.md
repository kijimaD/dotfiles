集中を削ぐサイトを遮断するプロキシサーバ。

ホストマシンの http://localhost:3128 を使う。

## 使い方

ACL_MODE: `priv` || `work`
省略した場合はprivateモードが使われる。

起動
```
ACL_MODE=priv make build-image
make up
```

再ビルドして再起動
```
ACL_MODE=priv make restart
```
