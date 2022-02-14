make_project:
	mkdir -p ~/Project
	mkdir -p ~/ProjectOrg
reload_ja_input:
	rm -rf ~/.cache/ibus
clone_roam:
	git clone git@github.com:kijimaD/roam.git ~/roam
swapcaps_gnome:
	gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:swapcaps']"
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

batch0:
	sudo apt-get update
	sudo apt-get install git syncthing cmigemo fcitx fcitx-mozc emacs-mozc rbenv peco
	guix pull
	source ~/dotfiles/.bash_profile

# TODO: 途中で失敗すると再実行が面倒(directory already exist error)
batch1:
	make init_packages
	make swapcaps_gnome
	make make_project
	make clone_roam
	make init_emacs
	make init_npm
	reload_ja_input
	cp_sensitive_files
	stow .

timestamp = ${shell date "+%Y%m%d%H%M%S"}
# imagemagick
take_ss:
	import ~/Desktop/${timestamp}.png

clone_user_projects:
	cd ~/Project && curl https://api.github.com/users/kijimaD/repos?per_page=100 | jq .[].ssh_url | xargs -n 1 git clone

PAGE=1
clone_org_projects:
	cd ~/ProjectOrg && curl "https://api.github.com/orgs/kd-collective/repos?per_page=100&page=$(PAGE)"  | jq .[].ssh_url | xargs -n 1 git clone
