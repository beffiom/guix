;;; System configuration for a Guix System with LUKS encrypted Btrfs
;;; on a Framework Laptop 13 (AMD, Early 2024).
;;;
;;; Save this file as /mnt/etc/config.scm after initial partitioning.
;;;
;;; Usage: sudo guix system init /mnt/etc/config.scm /mnt
;;; Then reboot.

(use-modules (gnu)
             (gnu services)
             (gnu services desktop)
             (gnu services ssh)
             (gnu services xorg)
             (gnu system)
             (gnu system nss)
             (gnu packages admin)
             (gnu packages bash)
             (gnu packages bsdutils)
             (gnu packages compression)
             (gnu packages curl)
             (gnu packages enlightenment) ; For elogind, which is needed by Wayland
             (gnu packages less)
             (gnu packages linux)         ; For the standard kernel from Guix
             (gnu packages password-utils)
             (gnu packages shells)
             (gnu packages suckless)
             (gnu packages wayland)
             (gnu packages xorg)
             (gnu packages network)
             (gnu packages terminals)
             (gnu packages virtualization) ; For virt-manager
             (nongnu packages linux)     ; For the linux kernel (with firmware)
             (nongnu packages browsers)  ; For chromium
             (nongnu services))          ; For nonguix-service-type and nonguix-channels

(define %my-username "beffiom")

(operating-system

  (host-name "guix")

  ;; Configure the system locale.
  (locale "en_US.utf8")

  ;; Allow use of non-free software through the 'nonguix' channel.
  (cons* (channel
          (name 'nonguix)
          (url "https://gitlab.com/nonguix/nonguix")
          ;; Enable signature verification:
          (introduction
           (make-channel-introduction
            "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
            (openpgp-fingerprint
             "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
         %default-channels)


  (kernel linux)

  ;; For Wayland, you typically need to add the input group to your user.
  (groups (cons* (user-group "input")
                 (user-group "video")
                 (user-group "audio")
                 (user-group "netdev")
                 %default-groups))

  ;; Set up the user account.
  (users (cons* (user-account
                  (name %my-username)
                  (comment "Ben")
                  (group "users")
                  (home-directory (string-append "/home/" %my-username))
                  ;; Set to 'hash-scl' with 'password-hash' or 'scrypt'
                  ;; to prevent plain text password in config.
                  ;; For initial setup, '("password" "your-initial-password")' is fine.
                  (password "your-initial-password-here")) ;; <<< CUSTOMIZE THIS
                %default-user-accounts))

  ;; System-wide packages. Add commonly used tools here.
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
             (specification->package "zstd") ; For Btrfs compression
             (specification->package "btrfs-progs") ; Btrfs utilities
             (specification->package "cryptsetup") ; LUKS utilities
             (specification->package "network-manager") ; For nmcli, nmtui
             (specification->package "linux-firmware") ; For common firmware blobs
             (specification->package "gparted") ; if you want a GUI partitioner later
             (specification->package "cgdisk") ; cli partitioner
             (specification->package "efibootmgr") ; For managing EFI boot entries
             (specification->package "amd-ucode") ; AMD CPU microcode updates
             (specification->package "wayland")
             (specification->package "wayland-utils")
             (specification->package "wl-clipboard") ; Wayland clipboard utils
             (specification->package "xdg-desktop-portal-wlr") ; Needed for screen sharing/portals
             (specification->package "xwayland") ; For running X11 apps on Wayland
             (specification->package "libva-utils") ; VA-API checks
             (specification->package "mesa") ; OpenGL implementation
             (specification->package "vulkan-loader") ; Vulkan loader
             (specification->package "vulkan-tools") ; Vulkan tools
             (specification->package "mesa-demos") ; glxinfo, glxgears, etc.
             %default-packages))

  ;; System services.
  (services (cons*
             ;; Standard services
             (service dbus-service-type)
             (service elogind-service-type)
             (service udev-service-type)
             (service linux-module-service-type
                      (linux-module-service-type-config
                       (modules (list "snd_sof_pci_amd_renoir" ; AMD audio
                                      "v4l2loopback" ; Webcam support
                                      "ucsi_ccg" "typec_ucsi" "ucsi_acpi" ; USB-C / PD
                                      "amd_pmc" "amd_pmc_core" ; AMD power management
                                      "kfd" "amdgpu" ; AMD graphics
                                      )))) ; Add more modules as needed for your specific hardware

             ;; Network services
             (service modem-manager-service-type)
             (service network-manager-service-type)
             ;; If you want a static IP or different network setup, you'd use
             ;; (service static-networking-service-type ...) instead.
             ;;
             ;; If you need specific Wi-Fi configuration (e.g., specific MAC address
             ;; for a persistent interface name), you can define it like so:
             ;; (service networking-service-type
             ;;          (extra-networking-configuration
             ;;           (list (network-config
             ;;                  (mac-address "XX:XX:XX:XX:XX:XX") ;; <<< CUSTOMIZE THIS
             ;;                  (interface-name "wlp1s0"))))) ;; <<< CUSTOMIZE THIS

             ;; SSH daemon
             (service openssh-service-type
                      (openssh-configuration
                       (port 22)
                       (permit-root-login 'no)
                       (password-authentication 'yes)))

             ;; For Wayland sessions to work correctly
             (service polkit-service-type)
             (service console-keymap-service-type
                      (console-keymap-service-type-config
                       (keymap "us")))

             ;; NonGuix Services for standard Linux kernel, firmware, etc.
             (service nonguix-service-type
                      (nonguix-configuration
                       (kernel-modules (list "amdgpu" "iwlwifi")) ; Add specific modules needing firmware
                       (firmware-packages (list (specification->package "linux-firmware")
                                                (specification->package "amd-gpu-firmware")))))
             %default-services))

  ;; Define the LUKS encrypted partition and its properties.
  ;; You MUST replace "YOUR_LUKS_PARTITION_UUID_HERE" with the actual UUID
  ;; of your /dev/nvme0n1p2 (use `sudo blkid`).
  (initrd-luks-devices (list (luks-device
                               (device (string-append "UUID=" "YOUR_LUKS_PARTITION_UUID_HERE")) ;; <<< CUSTOMIZE THIS
                               (name "cryptroot"))))

  ;; Define the file systems.
  ;; Replace "YOUR_BTRFS_FILESYSTEM_UUID_HERE" with the UUID of the Btrfs filesystem
  ;; on /dev/mapper/cryptroot (use `sudo blkid`).
  ;; Replace "YOUR_EFI_PARTITION_UUID_HERE" with the UUID of /dev/nvme0n1p1 (use `sudo blkid`).
  (file-systems (cons* (file-system
                         (mount-point "/boot/efi")
                         (device (string-append "UUID=" "YOUR_EFI_PARTITION_UUID_HERE")) ;; <<< CUSTOMIZE THIS
                         (type "vfat")
                         (dependencies (list "/")) ; Mount after root
                         (mount-options "umask=0077"))
                       (file-system
                         (mount-point "/")
                         (device (string-append "UUID=" "YOUR_BTRFS_FILESYSTEM_UUID_HERE")) ;; <<< CUSTOMIZE THIS
                         (type "btrfs")
                         (mount-options "noatime,compress=zstd:3,subvol=@root"))
                       (file-system
                         (mount-point "/home")
                         (device (string-append "UUID=" "YOUR_BTRFS_FILESYSTEM_UUID_HERE")) ;; <<< CUSTOMIZE THIS
                         (type "btrfs")
                         (mount-options "noatime,compress=zstd:3,subvol=@home"))
                       %default-file-systems))

  ;; GRUB bootloader configuration.
  (bootloader (bootloader-configuration
                (bootloader grub-bootloader)
                (target "/dev/nvme0n1") ;; <<< CUSTOMIZE THIS (your disk device)
                (efi-directory "/boot/efi")))

  (mapped-devices (list (mapped-device
                          (source "cryptroot")
                          (target (string-append "UUID=" "YOUR_LUKS_PARTITION_UUID_HERE"))))) ;; <<< CUSTOMIZE THIS

  ;; The 'extlinux-bootloader' is recommended for less common system architectures.
  ;; (bootloader (bootloader-configuration
  ;;              (bootloader extlinux-bootloader)
  ;;              (target "/dev/sda")))

  ;; Default to the Linux kernel from nonguix.
  (initrd-modules (cons* "amdgpu" "iwlwifi" %default-initrd-modules)) ;; Add more modules needed for early boot
  (kernel (string-append (package-output-path (specification->package "linux" "nonguix")) "/boot/vmlinuz"))
  (kernel-arguments (cons* "loglevel=4" "amd_iommu=on" "amdgpu.backlight=0" ; Add more kernel arguments for your hardware
                         %default-kernel-arguments)))
