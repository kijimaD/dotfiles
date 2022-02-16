(define syncthing
  (make <service>
    #:provides '(syncthing)
    #:respawn? #t
    #:start (make-forkexec-constructor '("syncthing" "-no-browser"))
    #:stop  (make-kill-destructor)))

(define redshift
  (make <service>
    #:provides '(redshift)
    #:respawn? #t
    #:start (make-forkexec-constructor '("redshift"))
    #:stop  (make-kill-destructor)))

(define dunst
  (make <service>
    #:provides '(dunst)
    #:respawn? #t
    #:start (make-forkexec-constructor '("dunst"))
    #:stop  (make-kill-destructor)))

(define ibus
  (make <service>
    #:provides '(ibus)
    #:respawn? #t
    #:start (make-forkexec-constructor '("ibus-daemon" "-x"))
    #:stop  (make-kill-destructor)))

(register-services syncthing redshift dunst)
(action 'shepherd 'daemonize)

;; Start user services
(for-each start '(syncthing redshift dunst))
