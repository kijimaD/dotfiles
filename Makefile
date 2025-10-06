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
	add_docker_group \
	init_run_emacs \
	clone_repos \
	init_guix

# Git管理しないファイルを初期化する
cp_sensitive_files:
	cp -n ~/dotfiles/.authinfo ~/

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

# ユーザをdockerグループに追加する。dockerをsudoなしで実行させるために必要
add_docker_group:
	sudo gpasswd -a $(shell whoami) docker
	id $(shell whoami)

# gcloneを使って、ファイルを基に明示的にcloneする
clone_repos:
ifeq ($(TEST),1)
	echo "not run"
else
	which gclone && gclone -f ~/dotfiles/gclone.yml
endif

# ================================

# convenient tasks

# ================================

# システムインストールのときのみ必要な初期設定
init_guix_system:
	sudo -E guix system reconfigure ~/.config/guix/system.scm

# Guixでファイルを基にパッケージをインストールする
init_packages:
	guix package -m ~/dotfiles/.config/guix/manifests/desktop.scm

# dotfilesをホームディレクトリに配置する(強制適用)
init_stow:
	stow . --adopt

# ibusの設定をリロードする
reload_ja_input:
	rm -rf ~/.cache/ibus

# # ディレクトリを英語化する
en_dir:
	LANG=C xdg-user-dirs-gtk-update

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
