;; ~/.config/guix/dwl-config.scm
;; ... (use-modules and definitions for terminal, tofi, etc.) ...
(use-modules (ice-9 popen)     ; For open-pipe*
             (ice-9 rts)       ; For system (to run notify-send)
             (gnu packages)
             (gnu packages terminals)
             (gnu packages suckless)
             (gnu packages gnome)) ; For libnotify / notify-send
             (guile-dwl config)
             (guile-dwl keysyms)
             (guile-dwl xdg)
             (gnu packages)
             (gnu packages suckless)
             (gnu packages wayland)
             (gnu packages terminals)
             (gnu packages browsers))

;; Program Declarations
(define notify-send-bin (string-append (package-output-path (specification->package "libnotify")) "/bin/notify-send"))
(define terminal (string-append (package-output-path (specification->package "foot")) "/bin/foot"))
(define tofi (string-append (package-output-path (specification->package "tofi")) "/bin/tofi"))
(define grim (string-append (package-output-path (specification->package "grim")) "/bin/grim"))
(define slurp (string-append (package-output-path (specification->package "slurp")) "/bin/slurp"))
(define wl-copy (string-append (package-output-path (specification->package "wl-clipboard")) "/bin/wl-copy"))
(define wl-paste (string-append (package-output-path (specification->package "wl-clipboard")) "/bin/wl-paste"))
(define chromium (string-append (package-output-path (specification->package "chromium")) "/bin/chromium"))
(define qutebrowser (string-append (package-output-path (specification->package "qutebrowser")) "/bin/qutebrowser"))

;; --- Window Rules ---
(define window-rules
  (list
   (make-rule :app-id "emacs" :tags (bitmask 0))
   (make-rule :app-id "qutebrowser" :tags (bitmask 1))
   (make-rule :app-id "org.chromium.Chromium" :tags (bitmask 2))
   (make-rule :app-id "terminal" :tags (bitmask 3))
   ))

;; Define tags. You mentioned 3 main contexts.
;; You can give them names here, though dwl itself just uses numbers/bitmasks.
(define tags (vector "emacs" "personal-browser" "work-browser" "terminal/misc"))

;; Default layout (0: tiling, 1: floating, 2: monocle/fullscreen)
(define default-layout 2) ;; Monocle by default for you!

;; Border pixel width (set to 0 for no borders)
(define border-pixel 0) ;; No borders!

;; Layouts definition. Here we define our preferred layouts.
;; The default dwl layouts often include tiling, floating, and monocle.
;; You might need to check the exact layout symbols your dwl-guile package supports.
(define layouts (vector (make-layout :symbol "[]=" :func tile-layout)
                        (make-layout :symbol "><>" :func float-layout)
                        (make-layout :symbol "[M]" :func monocle-layout)))

;; Keybindings (mod-mask is Super/Windows key)
(define mod-mask (bits 'super-mask))

(define keybindings
  (list
   ;; Applications
   (make-key-binding :mask mod-mask :key (sym->keysym 'Return) :command (spawn emacs))
   (make-key-binding :mask mod-mask :key (sym->keysym 't) :command (spawn terminal))
   (make-key-binding :mask mod-mask :key (sym->keysym 'd) :command (spawn tofi))
   (make-key-binding :mask mod-mask :key (sym->keysym 'w) :command (spawn chromium))
   (make-key-binding :mask (bits 'super-mask 'shift-mask) :key (sym->keysym 'w) :command (spawn qutebrowser))

   ;; Window management
   (make-key-binding :mask mod-mask :key (sym->keysym 'q) :command (kill-client))
   (make-key-binding :mask mod-mask :key (sym->keysym 'k) :command (focus-stack #t))  ;; Cycle through windows (next)
   (make-key-binding :mask mod-mask :key (sym->keysym 'j) :command (focus-stack #f)) ;; Cycle through windows (prev)
   (make-key-binding :mask mod-mask :key (sym->keysym 'h) :command (inc-master -1)) ;; Shrink master area
   (make-key-binding :mask mod-mask :key (sym->keysym 'l) :command (inc-master 1))  ;; Grow master area
   (make-key-binding :mask mod-mask :key (sym->keysym 'space) :command (cycle-layout)) ;; Cycle layouts

   ;; Tag switching (your "workspaces")
   (make-key-binding :mask mod-mask :key (sym->keysym '1) :command (view-tag 0)) ; View tag 0 ("emacs")
   (make-key-binding :mask mod-mask :key (sym->keysym '2) :command (view-tag 1)) ; View tag 1 ("personal-browser")
   (make-key-binding :mask mod-mask :key (sym->keysym '3) :command (view-tag 2)) ; View tag 2 ("work-browser")
   (make-key-binding :mask mod-mask :key (sym->keysym '4) :command (view-tag 2)) ; View tag 2 ("terminal/misc")
   ;; Add more tags if needed (e.g., 4, 5, 6...)

   ;; Move window to tag
   (make-key-binding :mask (bits 'super-mask 'shift-mask) :key (sym->keysym '1) :command (send-to-tag 0))
   (make-key-binding :mask (bits 'super-mask 'shift-mask) :key (sym->keysym '2) :command (send-to-tag 1))
   (make-key-binding :mask (bits 'super-mask 'shift-mask) :key (sym->keysym '3) :command (send-to-tag 2))
   (make-key-binding :mask (bits 'super-mask 'shift-mask) :key (sym->keysym '4) :command (send-to-tag 3))

   ;; Screenshots
   (make-key-binding :mask mod-mask :key (sym->keysym 's) :command (spawn (string-append slurp " | " grim " -g - " wl-copy))) ; Select area, copy to clipboard
   (make-key-binding :mask mod-mask :key (sym->keysym 'p) :command (spawn (string-append grim " - | " wl-copy))) ; Full screen, copy to clipboard

   ;; dwl restart/quit
   (make-key-binding :mask (bits 'super-mask 'shift-mask) :key (sym->keysym 'q) :command (quit))
   (make-key-binding :mask (bits 'super-mask 'shift-mask) :key (sym->keysym 'r) :command (restart))))
