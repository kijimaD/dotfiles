make_project:
	mkdir ~/Project
	mkdir ~/ProjectOrg
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

init_package:
	guix package -m ~/dotfiles/.config/guix/manifests/desktop.scm
init_npm:
	npm install npm

batch:
	make swapcaps_gnome
	make make_project
	make clone_roam
	make init_emacs
	make init_package
	make init_npm
	reload_ja_input
	cp_sensitive_files
	stow .

init_guix:
	guix pull
	sudo -E guix system reconfigure ~/.config/guix/system.scm

timestamp = ${shell date "+%Y%m%d%H%M%S"}

# imagemagick
take_ss:
	import ~/Desktop/${timestamp}.png

clone_user_projects:
	cd ~/Project && curl https://api.github.com/users/kijimaD/repos?per_page=100 | jq .[].ssh_url | xargs -n 1 git clone

clone_org_projects-1:
	cd ~/ProjectOrg && curl "https://api.github.com/orgs/kd-collective/repos?per_page=100&page=1"  | jq .[].ssh_url | xargs -n 1 git clone

clone_org_projects-2:
	cd ~/ProjectOrg && curl "https://api.github.com/orgs/kd-collective/repos?per_page=100&page=2"  | jq .[].ssh_url | xargs -n 1 git clone
