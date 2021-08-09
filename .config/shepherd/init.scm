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

(register-services syncthing redshift)
(action 'shepherd 'daemonize)

;; Start user services
(for-each start '(syncthing)) ;; redshift doesn't work properly...
