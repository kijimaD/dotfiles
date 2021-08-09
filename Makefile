make_project:
	mkdir ~/Project
reload_ja_input:
	rm -rf ~/.cache/ibus
clone_roam:
	git clone git@github.com:kijimaD/roam.git ~/roam
swapcaps_gnome:
	gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:swapcaps']"

clone_cask:
	git clone https://github.com/cask/cask ~/.cask
clone_emacs:
	git clone git@github.com:kijimaD/.emacs.d.git ~/.emacs.d
init_emacs:
	make clone_cask
	rm -rf ~/.emacs.d
	make clone_emacs
	cd ~/.emacs.d
	sh ~/.cask/bin/cask
	cd

init_package:
	guix package -m ~/dotfiles/.config/guix/manifests/desktop.scm

init_guix:
	guix pull
	sudo -E guix system reconfigure ~/.config/guix/system.scm

batch:
	make swapcaps_gnome
	make make_project
	make clone_roam
	make init_emacs
	make init_package
	reload_ja_input
	stow .
