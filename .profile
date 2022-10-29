# bashに依存しない
# GUIアプリで使うものやbin/sh で使うものを置く
# 例: 環境変数, PATH

# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# export PYENV_ROOT="$HOME/.pyenv"
# export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"
# PATH="/usr/local/heroku/bin:$PATH"

if [ -d "$HOME/.cargo" ] ; then
    . "$HOME/.cargo/env"
fi

if [ -d "$HOME/go" ] ; then
    # export PATH=$HOME/Project/go/bin:$PATH # 処理系

    export GOBIN=$HOME/go/bin
    export PATH=$GOBIN:$PATH # ライブラリのバイナリ
fi

if [ -d "$HOME/.rbenv" ] ; then
    eval "$(rbenv init -)"
    PATH="$HOME/.rbenv/bin:$PATH"
fi

if [ -d "$HOME/.cask" ] ; then
    PATH="$HOME/.cask/bin:$PATH"
fi

# Firefoxのスクロール
export MOZ_USE_XINPUT2=1

# setxkbmap -option ctrl:swapcaps
