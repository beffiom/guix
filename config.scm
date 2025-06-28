(use-modules (gnu)
    (gnu system nss)
    (gnu services)
    (gnu services desktop)
    (gnu services networking)
    (gnu services ssh)
    (gnu services linux)
    (gnu services dbus)
    (gnu services pm)
    (gnu packages)
    (gnu packages linux)
    (gnu packages networking)
    (gnu packages wm)
    (gnu packages version-control)
    (nongnu packages linux)
    (nongnu system linux-initrd))

;; Define username as a variable
(define %my-username "beffiom") ; Define this variable

(operating-system
(host-name "guix")

;; Configure the system locale.
(locale "en_US.utf8")
(timezone "America/New_York")

;; Use nonguix kernel
(kernel linux)
(initrd microcode-initrd)
(firmware (list linux-firmware))

;; Set up the user account.
(users (cons* (user-account
        (name %my-username)
        (comment "beffiom")
        (group "users")
        (home-directory (string-append "/home/" %my-username))
        (password (crypt "pass" "$6$abc")) ; Use proper password hashing
        (supplementary-groups '("wheel" "input" "video" "audio" "netdev")))
       %base-user-accounts))

;; System-wide packages.
(packages (append
    (list git
          neovim
          htop
          fzf
          ripgrep
          bat
          fd
          tldr
          wget
          curl
          zstd
          btrfs-progs
          cryptsetup
          network-manager
          linux-firmware
          gparted
          gdisk
          efibootmgr
          wayland
          wayland-protocols
          wl-clipboard
          xdg-desktop-portal-wlr
          xwayland
          mesa
          vulkan-loader
          vulkan-tools)
    %base-packages))

;; System services.
(services (append
    (list (service network-manager-service-type)
          (service wpa-supplicant-service-type)
          (service openssh-service-type
                   (openssh-configuration
                    (port-number 22)
                    (permit-root-login #f)
                    (password-authentication? #t))))
    %base-services))

;; GRUB bootloader configuration.
(bootloader (bootloader-configuration
      (bootloader grub-efi-bootloader)
      (targets '("/boot/efi"))
      (keyboard-layout keyboard-layout)))

;; Define the file systems.
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

;; Mapped devices for LUKS
(mapped-devices (list (mapped-device
                (source (uuid "5c0b9970-3065-46f0-8003-a05e8f6fec05"))
                (target "guix_luks")
                (type luks-device-mapping))))

;; Allow resolution of '.local' host names with mDNS.
(name-service-switch %mdns-host-lookup-nss))
