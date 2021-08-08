stow_all:
	stow -v backgrounds bash fonts git guile keyboard npm oyainput ruby
project:
	mkdir ~/Project
fonts:
	mkdir ~/.fonts
clone_roam:
	git clone git@github.com:kijimaD/roam.git ~/roam
clone_cask:
	git clone https://github.com/cask/cask ~/.cask
clone_emacs:
	rm -rf ~/.emacs.d && git clone git@github.com:kijimaD/.emacs.d.git ~/.emacs.d
