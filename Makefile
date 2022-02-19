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

test:
	if [ -d ~/dotfiles ]; then \
	  echo "not run" \
	else \
	  git clone https://github.com/kijimaD/dotfiles.git ~/dotfiles;
	fi
	make guix
	make install0 TEST="1" CLONE_STRATEGY="https://github.com/"
	make install1 TEST="1"

install0: make_project \
	clone_repos \
	key_theme \
	cp_sensitive_files \
	init_inotify \
	init_crontab \
	apt \
	guix

install1: cask_run \
	init_stow

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
	if [ $(TEST) ]; then \
	  echo "not run" \
	else \
	  crontab ~/dotfiles/crontab; \
	fi
init_inotify:
	echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
	sudo sysctl -p
init_spotify:
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	sudo flatpak install com.spotify.Client
apt:
	sudo apt-get update
	sudo DEBIAN_FRONTEND=noninteractive apt-get install -y cmigemo fcitx fcitx-mozc emacs-mozc rbenv peco silversearcher-ag docker docker-compose nvidia-driver-510
	if [ $(TEST) ]; then \
	  sudo apt-get install -y emacs stow; \
	fi

guix:
	if [ $(TEST) ]; then \
	  echo "not run" \
	else \
	  make init_guix; \
	fi
init_guix:
	cd /tmp && \
	wget https://git.savannah.gnu.org/cgit/guix.git/plain/etc/guix-install.sh && \
	chmod +x guix-install.sh && \
	yes | sudo ./guix-install.sh && \
	systemctl daemon-reload && \
	systemctl restart guix-daemon && \
	guix pull && \
	make init_packages

cask_run:
	cd ~/.emacs.d && ~/.cask/bin/cask

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

timestamp = ${shell date "+%Y%m%d%H%M%S"}
# imagemagick
take_ss:
	import ~/Desktop/${timestamp}.png

clone_user_projects:
	cd ~/Project && curl https://api.github.com/users/kijimaD/repos?per_page=100 | jq .[].ssh_url | xargs -n 1 git clone

PAGE=1
clone_org_projects:
	cd ~/ProjectOrg && curl "https://api.github.com/orgs/kd-collective/repos?per_page=100&page=$(PAGE)"  | jq .[].ssh_url | xargs -n 1 git clone
