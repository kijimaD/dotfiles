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
	cask_install \
	init_emacs \
	init_packages \
	init_npm \
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

test:
	make install CLONE_STRATEGY="https://github.com/"

install: make_project \
	clone_roam \
	key_theme \
	cp_sensitive_files

make_project:
	mkdir -p ~/Project
	mkdir -p ~/ProjectOrg
clone_roam:
	git clone $(CLONE_STRATEGY)kijimaD/roam.git ~/roam;
key_theme:
	if [ -d ~/.cinnamon ]; then\
	  gsettings set org.cinnamon.desktop.interface gtk-key-theme Emacs; \
	fi
cp_sensitive_files:
	cp ~/dotfiles/.authinfo ~/
	cp ~/dotfiles/.gitconfig ~/

clone_cask:
	git clone https://github.com/cask/cask ~/.cask
clone_emacs:
	git clone git@github.com:kijimaD/.emacs.d.git ~/.emacs.d
cask_install:
	cd ~/.emacs.d && sh ~/.cask/bin/cask

init_emacs:
	make clone_cask
	rm -rf ~/.emacs.d
	make clone_emacs
	make cask_install

init_packages:
	guix package -m ~/dotfiles/.config/guix/manifests/desktop.scm
init_npm:
	npm install npm
init_guix_system: # システムインストールのときのみ必要
	sudo -E guix system reconfigure ~/.config/guix/system.scm
init_guix:
	cd /tmp && \
	wget https://git.savannah.gnu.org/cgit/guix.git/plain/etc/guix-install.sh && \
	chmod +x guix-install.sh && \
	yes | sudo ./guix-install.sh
init_crontab:
	crontab ~/dotfiles/crontab
init_inotify:
	echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
	sudo sysctl -p
init_spotify:
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	sudo flatpak install com.spotify.Client

batch0:
	sudo apt-get update
	sudo apt-get install -y git syncthing cmigemo fcitx fcitx-mozc emacs-mozc rbenv peco silversearcher-ag docker docker-compose nvidia-driver-510
	guix pull
	source ~/dotfiles/.bash_profile

# TODO: 途中で失敗すると再実行が面倒(directory already exist error)
batch1:
	make init_packages
	make key_theme
	make make_project
	make clone_roam
	make init_emacs
	make init_npm
	reload_ja_input
	cp_sensitive_files
	stow .

# ================================

# convenient tasks

# ================================

timestamp = ${shell date "+%Y%m%d%H%M%S"}
# imagemagick
take_ss:
	import ~/Desktop/${timestamp}.png

reload_ja_input:
	rm -rf ~/.cache/ibus

clone_user_projects:
	cd ~/Project && curl https://api.github.com/users/kijimaD/repos?per_page=100 | jq .[].ssh_url | xargs -n 1 git clone

PAGE=1
clone_org_projects:
	cd ~/ProjectOrg && curl "https://api.github.com/orgs/kd-collective/repos?per_page=100&page=$(PAGE)"  | jq .[].ssh_url | xargs -n 1 git clone
