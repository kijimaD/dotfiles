set -e
trap 'echo "ERROR: line no = $LINENO, exit status = $?" >&2; exit 1' ERR

# System Guix ================
# # japanese input settings
# export GUIX_GTK2_IM_MODULE_FILE="$HOME/.guix-profile/lib/gtk-2.0/2.10.0/immodules-gtk2.cache"
# export GUIX_GTK3_IM_MODULE_FILE="$HOME/.guix-profile/lib/gtk-3.0/3.0.0/immodules-gtk3.cache"

# non-system Guix settings ================
GUIX_PROFILE="$HOME/.guix-profile"
. "$GUIX_PROFILE/etc/profile"
GUIX_PROFILE="$HOME/.config/guix/current"
. "$GUIX_PROFILE/etc/profile"
export GUIX_LOCPATH="$HOME/.guix-profile/lib/locale"

source "$HOME/.guix-profile/etc/profile"
source "$HOME/.config/guix/current/etc/profile"

export PATH="$HOME/.config/guix/current/bin:$PATH"
export INFOPATH="$HOME/.config/guix/current/share/info:$INFOPATH"

export SSL_CERT_DIR="$HOME/.guix-profile/etc/ssl/certs"
export SSL_CERT_FILE="$HOME/.guix-profile/etc/ssl/certs/ca-certificates.crt"
export GIT_SSL_CAINFO="$SSL_CERT_FILE"

# Git ================
function parse_git_branch_and_add_brackets {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\ \[\1\]/'
}
PS1="\h:\W \u\[\033[0;32m\]\$(parse_git_branch_and_add_brackets) \[\033[0m\]\$ "

# Adjust the prompt depending on whether we're in 'guix environment'.
if [ -n "$GUIX_ENVIRONMENT" ]
then
    PS1='\u@\h \w [env]\$ '
else
    PS1='\u@\h \w\$ '
fi

# Emacs
if [[ "$INSIDE_EMACS" = 'vterm' ]] \
    && [[ -n ${EMACS_VTERM_PATH} ]] \
    && [[ -f "${EMACS_VTERM_PATH}"/etc/emacs-vterm-bash.sh ]]; then
    source "${EMACS_VTERM_PATH}"/etc/emacs-vterm-bash.sh
fi

# General ================
alias ls='ls -p --color=auto'
alias ll='ls -l'
alias grep='grep --color=auto'

# qute browser font size
export QT_SCALE_FACTOR=2

# save history
export PROMPT_COMMAND='history -a;history -c;history -r'

eval "$(rbenv init -)"
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/python:$PATH"
export PATH="$HOME/.cask/bin:$PATH"
