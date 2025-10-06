## 運用

```shell
home-manager switch --flake .#violet
```

## クリーンインストールする手順

gistを参照する。

## 仮想イメージで試す手順

apt install -y qemu-kvm

1. 空のディスクイメージを作成:
qemu-img create -f qcow2 ubuntu.qcow2 100G

2. ISOからインストール:
qemu-system-x86_64 \
  -enable-kvm -m 4096 \
  -hda mint.qcow2 \
  -cdrom linuxmint-22.2-cinnamon-64bit.iso \
  -boot d

3. ISOなしで起動する:
qemu-system-x86_64 -enable-kvm -m 4096 -hda mint.qcow2
