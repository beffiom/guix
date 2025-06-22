;;; Guix Home Configuration for Ben
;;;
;;; Save this file as ~/.config/guix/home.scm (or symlink your dotfiles)
;;;
;;; Usage: guix home reconfigure ~/.config/guix/home.scm

(use-modules (gnu home)
             (gnu home services)
             (gnu home services desktop)
             (gnu home services suckless) ; For dwl-guile
             (gnu home services shells)
             (gnu home services mcron)    ; For mcron-service-type for scripts
             (gnu home services pam)      ; For pam-service-type for authentication
             (gnu packages)
             (gnu packages admin)
             (gnu packages bash)
             (gnu packages bsdutils)
             (gnu packages compression)
             (gnu packages enlightenment)
             (gnu packages less)
             (gnu packages linux)
             (gnu packages password-utils)
             (gnu packages shells)
             (gnu packages suckless)
             (gnu packages terminals)
             (gnu packages wayland)
             (gnu packages xorg)
             (gnu packages network)
             (nongnu packages browsers)
             (nongnu packages linux))

(define %my-username "beffiom")

(home-environment
  (host-name "guix")
  (operating-system (operating-system)) ;; Refers to the system config

  ;; User's list of packages
  (packages (cons*
             (specification->package "dwl-guile")
             (specification->package "git")
             (specification->package "neovim")
             (specification->package "tmux")
             (specification->package "htop")
             (specification->package "fzf")
             (specification->package "ripgrep")
             (specification->package "bat")
             (specification->package "fd")
             (specification->package "tldr")
             (specification->package "wget")
             (specification->package "curl")
             (specification->package "zstd")
             (specification->package "btrfs-progs")
             (specification->package "cryptsetup")
             (specification->package "network-manager")
             (specification->package "linux-firmware")
             (specification->package "gnome-keyring")
             (specification->package "efibootmgr")
             (specification->package "amd-ucode")
             (specification->package "wayland")
             (specification->package "wayland-utils")
             (specification->package "foot")
             (specification->package "tofi")
             (specification->package "grim")
             (specification->package "slurp")
             (specification->package "wl-clipboard")
             (specification->package "wl-clipboard-x11")
             (specification->package "cliphist")
             (specification->package "xdg-desktop-portal-wlr")
             (specification->package "xwayland")
             (specification->package "libva-utils")
             (specification->package "mesa")
             (specification->package "vulkan-loader")
             (specification->package "vulkan-tools")
             (specification->package "mesa-demos")
             (specification->package "chromium")
             (specification->package "qutebrowser")
             (specification->package "clojure")
             (specification->package "python")
             (specification->package "python-pip")
             (specification->package "swaybg")
             (specification->package "swayidle")
             (specification->package "ncmpcpp")
             (specification->package "mpd")
             (specification->package "mpv")
             (specification->package "mpv-mpris")
             (specification->package "ffmpeg")
             (specification->package "ffmpegthumbnailer")
             (specification->package "bluez")
             (specification->package "bluez-alsa")
             (specification->package "pipewire")
             (specification->package "pulseaudio")
             (specification->package "pulsemixer")
             (specification->package "pa-notify")
             (specification->package "yt-dlp")
             (specification->package "gallery-dl")
             (specification->package "lf")
             (specification->package "neomutt")
             (specification->package "nushell")
             (specification->package "dunst")
             (specification->package "libnotify")
             (specification->package "light")
             (specification->package "inotify-tools")
             (specification->package "font-awesome")
             (specification->package "font-fira-sans")
             (specification->package "brightnessctl")
             (specification->package "unzip")
             (specification->package "rbw")
             (specification->package "podman")
             (specification->package "zathura")
             ;; Add any other user-specific packages here
             %default-home-packages))

  ;; User-specific services.
  (services (cons*
             ;; Wayland setup, especially for dwl
             (service home-xdg-configuration-service-type)
             (service home-dbus-service-type)
             (service home-elogind-session-service-type)
             (service home-polkit-agent-service-type)
             (service home-pam-service-type) ;; Ensures pam is setup for things like polkit-agent
             (service home-terminal-emulator-service-type ; Sets up foot as default terminal
                      (home-terminal-emulator-service-type-config
                       (terminal-emulator foot)))

             ;; dwl-guile: This is where you configure dwl-guile!
             (service dwl-guile-home-service-type
                      (dwl-guile-home-configuration
                       (guile-config-file (string-append
                                           (getcwd) ; Current directory of this home.scm
                                           "/dwl-config.scm")) ; A separate file for dwl's config
                       (extra-environment-variables
                        '(("MOZ_ENABLE_WAYLAND" "1") ; For Firefox Wayland support
                          ("QT_QPA_PLATFORM" "wayland") ; For Qt apps Wayland support
                          ("GTK_THEME" "Adwaita:dark"))))) ; Example GTK theme

             ;; Optional: Notification Daemon (e.g., for battery alerts)
             (service home-notifd-service-type)

             ;; Optional: Screen Locker (e.g., swaylock)
             (service home-swaylock-service-type
                      (home-swaylock-configuration
                       (command (list (string-append (package-output-path (specification->package "swaylock")) "/bin/swaylock")))))

             ;; Optional: Cron jobs (e.g., for battery notifications)
             (service home-mcron-service-type
                      (mcron-configuration
                       (jobs (list
                              ;; Example battery notification script (adjust script path)
                              (job "*/5 * * * *"
                                   (string-append
                                    (getenv "HOME") "/.config/guix/scripts/battery-notify.sh"))))))

             %default-home-services)))
