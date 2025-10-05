## 運用

```shell
home-manager switch --flake .#violet
```

## クリーンインストールする手順

```shell
git clone git@github.com:kijimaD/dotfiles.git

curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate

cd ~/dotfiles/nix
nix run home-manager/master -- switch --flake .#violet

stow .
```
