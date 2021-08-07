stow_all:
	stow -v autostart bash fish fonts git guile guix keyboard npm nyxt oyainput ruby
project:
	mkdir Project
fonts:
	mkdir .fonts
clone_roam:
	git clone git@github.com:kijimaD/roam.git
clone_cask:
	git clone https://github.com/cask/cask ~/.cask
