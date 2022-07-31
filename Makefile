# ================================

# build system

# ================================

.PHONY: test \
	no_depends \
	make_project \
	reload_ja_input \
	clone_roam \
	key_theme \
	cp_sensitive_files \
	clone_cask \
	clone_emacs \
	cask_run \
	init_packages \
	init_guix_system \
	init_guix \
	init_crontab \
	init_inotify \
	init_spotify \
	batch0 \
	batch1 \
	take_ss \
	clone_user_projects \
	clone_org_projects

CLONE_STRATEGY = "git@github.com:"

ci:
	git clone https://github.com/kijimaD/dotfiles.git ~/dotfiles
	make guix
	make test

test:
	make install0 TEST=1 CLONE_STRATEGY="https://github.com/"
	make install1 TEST=1

install0: make_project \
	clone_repos \
	key_theme \
	cp_sensitive_files \
	init_inotify \
	init_crontab \
	apt \
	guix

install1: init_stow \
	cask_run

make_project:
	mkdir -p ~/Project
	mkdir -p ~/ProjectOrg
clone_repos:
	git clone $(CLONE_STRATEGY)kijimaD/roam.git ~/roam;
	git clone $(CLONE_STRATEGY)cask/cask ~/.cask
	git clone $(CLONE_STRATEGY)kijimaD/.emacs.d.git ~/.emacs.d
key_theme:
	if [ -d ~/.cinnamon ]; then \
	  gsettings set org.cinnamon.desktop.interface gtk-key-theme Emacs; \
	fi
cp_sensitive_files:
	cp ~/dotfiles/.authinfo ~/
	cp ~/dotfiles/.gitconfig ~/
init_crontab:
ifeq ($(TEST),1)
	echo "init_crontab not run"
else
	crontab ~/dotfiles/crontab
endif
init_inotify:
	echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
	sudo sysctl -p
init_spotify:
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	sudo flatpak install com.spotify.Client
apt:
	sudo apt-get update
	sudo DEBIAN_FRONTEND=noninteractive apt-get install -y cmigemo fcitx fcitx-mozc emacs-mozc rbenv peco silversearcher-ag docker docker-compose nvidia-driver-510
ifeq ($(TEST),1)
	sudo apt-get install -y emacs stow
endif

guix:
ifeq ($(TEST),1)
	echo "guix not run"
else
	make init_guix;
endif
init_guix:
	cd /tmp && \
	wget https://git.savannah.gnu.org/cgit/guix.git/plain/etc/guix-install.sh && \
	chmod +x guix-install.sh && \
	yes | sudo ./guix-install.sh && \
	. ~/.bashrc && \
	sudo systemctl daemon-reload && \
	sudo systemctl restart guix-daemon && \
	guix pull && \
	cd ~/dotfiles && \
	make init_packages

cask_run:
ifeq ($(TEST),1)
	echo "cask_run not run"
else
	cd ~/.emacs.d && ~/.cask/bin/cask
endif

# ================================

# convenient tasks

# ================================

init_guix_system: # システムインストールのときのみ必要
	sudo -E guix system reconfigure ~/.config/guix/system.scm

init_packages:
	guix package -m ~/dotfiles/.config/guix/manifests/desktop.scm

init_stow:
	stow .

reload_ja_input:
	rm -rf ~/.cache/ibus

en_dir: # ディレクトリを英語化
	LANG=C xdg-user-dirs-gtk-update

timestamp = ${shell date "+%Y%m%d%H%M%S"}
# imagemagick
take_ss:
	import ~/Desktop/${timestamp}.png

clone_user_projects:
	cd ~/Project && curl https://api.github.com/users/kijimaD/repos?per_page=100 | jq .[].ssh_url | xargs -n 1 git clone

PAGE=1
clone_org_projects:
	cd ~/ProjectOrg && curl "https://api.github.com/orgs/kd-collective/repos?per_page=100&page=$(PAGE)"  | jq .[].ssh_url | xargs -n 1 git clone

cloner:
	cargo install cloner && cloner ./project.toml && cloner ./project_org.toml

clean:
	docker builder prune
	docker volume prune
	git gc
	git fetch --prune

restart_bt:
	sudo systemctl restart bluetooth.service

restart_wm:
	sudo systemctl restart display-manager
