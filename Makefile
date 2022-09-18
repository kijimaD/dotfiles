# ================================

# build system
# ベースイメージで実行していることを前提にしている。
# https://github.com/kijimaD/dotfiles/releases

# ================================

.PHONY: test \
	cp_sensitive_files \
	init_packages \
	init_guix_system \
	init_guix \
	init_crontab \
	init_inotify \
	take_ss \
	clone_all_user_projects \
	clone_all_org_projects \
	clone_repos

# テストで実行用
test:
	make install TEST=1

# メインコマンド
install: cp_sensitive_files \
	init_inotify \
	init_crontab \
	init_guix \
	add_docker_group \
	init_run_emacs \
	init_go \
	clone_repos

# Git管理しないファイルを初期化する
cp_sensitive_files:
	cp -n ~/dotfiles/.authinfo ~/
	cp -n ~/dotfiles/.gitconfig ~/

# サーバ起動でエラーになることがあるのでinotifyの数を増やす
init_inotify:
	echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
	sudo sysctl -p

# 定期タスクを設定する
init_crontab:
ifeq ($(TEST),1)
	echo "init_crontab not run"
else
	crontab ~/dotfiles/crontab
endif

# Guix本体とパッケージ関連をすべて設定する
init_guix:
ifeq ($(TEST),1)
	echo "guix not run"
else
	cd /tmp && \
	wget https://git.savannah.gnu.org/cgit/guix.git/plain/etc/guix-install.sh && \
	chmod +x guix-install.sh && \
	yes | sudo ./guix-install.sh && \
	. ~/.bashrc && \
	sudo systemctl daemon-reload && \
	sudo systemctl restart guix-daemon && \
	guix pull && \
	hash guix && \
	cd ~/dotfiles && \
	make init_packages
endif

init_run_emacs:
	emacs -nw --batch --load ~/.emacs.d/init.el --eval '(all-the-icons-install-fonts t)'

init_go:
	go install golang.org/x/tools/gopls@latest # LSP
	go install github.com/go-delve/delve/cmd/dlv@latest # debugger

# ユーザをdockerグループに追加する。dockerをsudoなしで実行させるために必要
add_docker_group:
	sudo gpasswd -a $(shell whoami) docker
	id $(shell whoami)

# clonerを使って、ファイルを基に明示的にcloneする
clone_repos:
ifeq ($(TEST),1)
	echo "not run"
else
	which cloner && cloner ./cloner/project.toml && cloner ./cloner/project_org.toml
endif

# ================================

# convenient tasks

# ================================

# システムインストールのときのみ必要な初期設定
init_guix_system:
	sudo -E guix system reconfigure ~/.config/guix/system.scm

# Guixでファイルに基にパッケージをインストールする
init_packages:
	guix package -m ~/dotfiles/.config/guix/manifests/desktop.scm

# dotfilesをホームディレクトリに配置する
init_stow:
	stow .

# ibusの設定をリロードする
reload_ja_input:
	rm -rf ~/.cache/ibus

# # ディレクトリを英語化する
en_dir:
	LANG=C xdg-user-dirs-gtk-update

# 100ごとにclone。多すぎて使いにくい
clone_all_user_projects:
	cd ~/Project && curl https://api.github.com/users/kijimaD/repos?per_page=100 | jq .[].ssh_url | xargs -n 1 git clone

# 100ごとにclone。多すぎて使いにくい
PAGE=1
clone_all_org_projects:
	cd ~/ProjectOrg && curl "https://api.github.com/orgs/kd-collective/repos?per_page=100&page=$(PAGE)"  | jq .[].ssh_url | xargs -n 1 git clone

# 不要なファイルを削除する
clean:
	docker builder prune
	docker volume prune
	git gc
	git fetch --prune

# 再起動する
restart_bt:
	sudo systemctl restart bluetooth.service

# 再起動する
restart_wm:
	sudo systemctl restart display-manager

# GitHubからダウンロードしたartifact.zipからisoを展開して、qemuで起動する
run_artifacts:
	cd ~/Downloads && \
	unzip artifact.zip && \
	rm -f build.iso && \
	(cat ./kd-ubuntu-20.04.3-desktop-amd64.iso-* > ./build.iso) && \
	rm -rf kd-ubuntu-20.04.3-desktop-amd64* artifact.zip && \
	qemu-system-x86_64 -boot d -cdrom ./build.iso -enable-kvm -m 4096

run_releases:
	cd ~/Downloads && \
	(cat ./kd-ubuntu-20.04.3-desktop-amd64.iso-* > ./build.iso) && \
	rm -rf kd-ubuntu-20.04.3-desktop-amd64* artifact.zip && \
	qemu-system-x86_64 -boot d -cdrom ./build.iso -enable-kvm -m 4096
