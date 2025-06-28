;; This is an operating system configuration for a desktop setup
;; with Wayland/Sway, nonguix kernel, and LUKS encryption.

(use-modules (gnu)
             (gnu system nss)
             (gnu services)
             (gnu services desktop)
             (gnu services networking)
             (gnu services ssh)
             (gnu services linux)
             (gnu services dbus)              ; Added for dbus-service-type
             (gnu packages)
             (gnu packages linux)
             (gnu packages version-control)    ; for git
             (gnu packages vim)                ; for neovim
             (gnu packages admin)              ; for htop
             (gnu packages terminals)          ; for terminal emulators
             (gnu packages rust-apps)          ; for fzf, ripgrep, bat, fd
             (gnu packages web)                ; for wget, curl
             (gnu packages compression)        ; for zstd
             (gnu packages disk)               ; for btrfs-progs, gparted, gdisk
             (gnu packages cryptsetup)         ; for cryptsetup
             (gnu packages networking)         ; for network-manager
             (gnu packages gnome)              ; for gparted
             (gnu packages wget)
             (gnu packages curl)
             (gnu packages freedesktop)        ; for xdg-desktop-portal-wlr, wayland, wayland-protocols
             (gnu packages wm)                 ; for sway, waybar
             (gnu packages xdisorg)            ; for wayland utilities
             (gnu packages gl)                 ; for mesa
             (gnu packages vulkan)             ; for vulkan-loader, vulkan-tools
             (nongnu packages linux)
             (nongnu system linux-initrd))

(operating-system
  (host-name "guix")
  (timezone "America/New_York")
  (locale "en_US.utf8")
  (keyboard-layout (keyboard-layout "us"))

  ;; Use nonguix kernel
  (kernel linux)
  (initrd microcode-initrd)
  (firmware (list linux-firmware))

  ;; Bootloader configuration for UEFI
  (bootloader (bootloader-configuration
               (bootloader grub-efi-bootloader)
               (targets '("/boot/efi"))))

  ;; Mapped devices for LUKS encryption
  (mapped-devices (list (mapped-device
                         (source (uuid "5c0b9970-3065-46f0-8003-a05e8f6fec05"))
                         (target "guix_luks")
                         (type luks-device-mapping))))

  ;; File systems
  (file-systems (cons* (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "9BA1-F232" 'fat32))
                         (type "vfat"))
                       
                       (file-system
                         (mount-point "/boot")
                         (device (uuid "7663a7ea-d2fe-4862-aa64-173c5a2badba"))
                         (type "ext2"))
                       
                       (file-system
                         (mount-point "/")
                         (device "/dev/mapper/guix_luks")
                         (type "btrfs")
                         (options "noatime,compress=zstd:3,subvol=@")
                         (dependencies mapped-devices))
                       
                       (file-system
                         (mount-point "/home")
                         (device "/dev/mapper/guix_luks")
                         (type "btrfs")
                         (options "noatime,compress=zstd:3,subvol=@home")
                         (dependencies mapped-devices))
                       
                       %base-file-systems))

  ;; User accounts
  (users (cons* (user-account
                 (name "beffiom")
                 (comment "beffiom")
                 (group "users")
                 (home-directory "/home/beffiom")
                 (supplementary-groups '("wheel" "input" "video" "audio" "netdev" "docker")))
                %base-user-accounts))

  ;; System-wide packages
  (packages (append
             (list git
                   neovim
                   htop
                   fzf
                   ripgrep
                   bat
                   fd
                   tealdeer  ; Replacement for tldr
                   wget
                   curl
                   zstd
                   btrfs-progs
                   cryptsetup
                   network-manager
                   linux-firmware
                   gparted
                   efibootmgr
                   ;; Wayland packages (from freedesktop and wm modules)
                   sway
                   swaylock
                   swayidle
                   waybar
                   wayland
                   wayland-protocols
                   wl-clipboard
                   xdg-desktop-portal-wlr
                   ;; Graphics
                   mesa
                   vulkan-loader
                   vulkan-tools)
             %base-packages))

  ;; System services
  (services (append
             (list (service network-manager-service-type)
                   (service wpa-supplicant-service-type)
                   (service openssh-service-type
                            (openssh-configuration
                             (port-number 22)
                             (permit-root-login #f)
                             (password-authentication? #t)))
                   ;; Desktop services for Wayland
                   (service elogind-service-type)
                   (service dbus-service-type)
                   (service polkit-service-type)
                   (service fontconfig-file-system-service))
             %base-services))

  ;; Allow resolution of '.local' host names with mDNS
  (name-service-switch %mdns-host-lookup-nss))
