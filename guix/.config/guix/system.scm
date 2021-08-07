;; This is an operating system configuration generated
;; by the graphical installer.

(use-modules (gnu) (nongnu packages linux))
(use-service-modules desktop networking ssh xorg)

(operating-system
 (kernel linux)
 (firmware (list linux-firmware))
  (locale "en_US.utf8")
  (timezone "Asia/Tokyo")
  (keyboard-layout
    (keyboard-layout
      "jp,us"
      #:options
      '("grp:alt_shift_toggle" "ctrl:nocaps")))
  (host-name "kijimad")
  (users (cons* (user-account
                  (name "kijimad")
                  (comment "Kijima Daigo")
                  (group "users")
                  (home-directory "/home/kijimad")
                  (supplementary-groups
                    '("wheel" "netdev" "audio" "video")))
                %base-user-accounts))
  (packages
    (append
      (list (specification->package "emacs")
            (specification->package "emacs-exwm")
            (specification->package
              "emacs-desktop-environment")
            (specification->package "nss-certs"))
      %base-packages))
  (services
    (append
      (list (service gnome-desktop-service-type)
            (set-xorg-configuration
              (xorg-configuration
                (keyboard-layout keyboard-layout))))
      %desktop-services))
  (bootloader
    (bootloader-configuration
      (bootloader grub-bootloader)
      (target "/dev/sda")
      (keyboard-layout keyboard-layout)))
  (swap-devices
    (list (uuid "886d2ab5-cf85-4271-88e3-1c54c32432b8")))
  (file-systems
    (cons* (file-system
             (mount-point "/boot/efi")
             (device
               (uuid "321659ff-63f7-4ad1-8903-fe2b74a8fc05"
                     'ext4))
             (type "ext4"))
           (file-system
             (mount-point "/")
             (device
               (uuid "e381cb98-2174-49d7-9883-a94fa957a86f"
                     'ext4))
             (type "ext4"))
           %base-file-systems)))
