(define-configuration buffer
  ((default-modes (append '(emacs-mode) %slot-default%))))

(defvar *my-keymap* (make-keymap "my-map"))
(define-key *my-keymap*
  "C-o" 'nyxt/web-mode:follow-hint)
