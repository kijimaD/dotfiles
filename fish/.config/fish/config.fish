set PATH "$HOME/.rbenv/bin" $PATH
set PATH "$HOME/.cask/bin" $PATH
status --is-interactive; and source (rbenv init -|psub)
set -gx OMF_PATH $HOME/.local/share/omf
set fish_theme bira
