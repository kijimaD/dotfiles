(define syncthing
  (make <service>
    #:provides '(syncthing)
    #:respawn? #t
    #:start (make-forkexec-constructor '("syncthing" "-no-browser"))
    #:stop  (make-kill-destructor)))

(register-services syncthing)
(action 'shepherd 'daemonize)

;; Start user services
(for-each start '(syncthing))
