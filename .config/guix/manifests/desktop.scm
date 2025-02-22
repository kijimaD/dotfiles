;; desktop settings

(specifications->manifest
 '(
   ;; code
   "git"
   ;; "gcc-toolchain"
   "glibc-locales"
   "make"
   "jq"
   "pkg-config"
   "texinfo"
   ;; "llvm"
   ;; "lld"
   ;; "clang"
   "file"
   "elfutils"
   "stow"
   ;; FIXME: v1.0.0以上だとconfigエラーになる...
   ;; guix install shepherd@0.10.5
   "shepherd"
   "ripgrep"

   ;; language
   "ruby"

   ;; package system
   "node"

   ;; network
   ;; "openssh"
   "curl"
   "nss-certs"

   ;; lock
   ;; "xautolock"
   ;; "xset"

   ;; docker
   ;; "docker"
   ;; "docker-cli"
   ;; "docker-compose"

   ;; desktop
   "syncthing"
   "polybar"
   ;; "qutebrowser"
   ;; "nyxt"
   "redshift"
   "obs"

   ;; japanese input
   ;; "ibus"
   ;; "ibus-anthy"
   "font-adobe-source-han-sans"
   "fcitx"

   ;; emacs
   ;; "emacs"
   ;; "emacs-emacsql"
   ;; "emacs-vterm"
   ;; "emacs-org-roam"
   "cmake"
   "libtool"
   "libvterm"

   ;; backup
   ;; "deja-dup"

   ;; "polybar"
   ;; "compton"
   "feh"
   "font-awesome"
   ;; "imagemagick"

   ;; notification
   "dunst"

   ;; cmd media player
   "playerctl"
   ))
