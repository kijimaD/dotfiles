export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
export PATH="$HOME/python:$PATH"
export PATH="$HOME/.cask/bin:$PATH"

GUIX_PROFILE="$HOME/.guix-profile"
. "$GUIX_PROFILE/etc/profile"
GUIX_PROFILE="$HOME/.config/guix/current"
. "$GUIX_PROFILE/etc/profile"
export GUIX_LOCPATH="$HOME/.guix-profile/lib/locale"

# save history
export PROMPT_COMMAND='history -a;history -c;history -r'

# github/guix.el
source "$HOME/.guix-profile/etc/profile"
source "$HOME/.config/guix/current/etc/profile"
