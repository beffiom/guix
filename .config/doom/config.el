;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; disable autosave
(setq auto-save-default nil)

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-homage-black)
(set-frame-parameter (selected-frame) 'alpha-background 65)
(add-to-list 'default-frame-alist '(alpha-background . 65))

;; Set tab width
(setq-default indent-tabs-mode 0)
(setq tab-width 4)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)
(setq global-word-wrap-whitespace-mode-buffers nil)

(add-hook 'org-mode-hook (lambda () (org-autolist-mode)))

(add-hook 'org-mode-hook
          (lambda ()
            (darkroom-mode 1)
            (menu-bar--display-line-numbers-mode-none)))

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Drive/Notes/")
(setq org-hide-emphasis-markers t)
(setq org-src-block-background (face-attribute 'default :background))
(setq org-src-block-padding 10)
(setq org-src-block-frame-width 2)
(setq org-src-block-face '(:background "#f0f0f0" :border "1px solid #ddd" :border-radius "4px" :box-shadow "0 0 10px rgba(0,0,0,0.1)"))
(setq org-src-block-frame-color "#333333")
(setq org-list-auto-continuation t)
(setq org-list-allow-alphabetical-continuation t)
(map! :leader "m d" #'darkroom-mode)
(setq darkroom-margins-if-failed-guess 0.25)
(setq darkroom-margins 0.25)
(setq org-level-faces
      '((title (:height 1.4 :bold t)) ; Title (largest)
        (1 (:height 1.2 :bold t)) ; H1
        (2 (:height 1.0)) ; H2
        (3 (:height 0.9)) ; H3
        (4 (:height 0.8)) ; H4
        (5 (:height 0.7)) ; H5
        (6 (:height 0.6)))) ; H6 (smallest)
(add-hook 'org-mode-hook
          (lambda ()
            (push '("[ ]" .  "") prettify-symbols-alist)
            (push '("[X]" . "󰱒" ) prettify-symbols-alist)
            (push '("[-]" . "󱗝" ) prettify-symbols-alist)
            (push '("-" . "" ) prettify-symbols-alist)
            (prettify-symbols-mode)))
(setq org-checkbox-foreground "green") ; Completed checkboxes
(use-package org-superstar
  :ensure t
  :config
  (org-superstar-mode 1))

;; Customize org bullets
(setq org-superstar-headline-bullets-list '("◉" "○" "✸" "✿" "○" "✸" "✿" "○" "✸" "✿"))

;; Dired Image Preview
(after! dired
  (setq dired-image-preview-enabled t)
  (setq image-dired-thumb-size 100))  ; Optional: Set preview size
;; Dired Open Images and Videos in mpv
(after! dired
  (setq dired-external-viewer-alist
        '(("\\.\\(jpg\\|jpeg\\|png\\|gif\\|bmp\\)$" . "mpv")
          ("\\.\\(mp4\\|mkv\\|webm\\|avi\\|mov\\)$" . "mpv"))))

;; Remap previous-buffer to backspace in normal mode
(after! evil
  (define-key evil-normal-state-map (kbd "DEL") #'previous-buffer))

;; Set wl-clipboard as default keyboard
(setq select-enable-clipboard t)
(setq interprogram-paste-function 'wl-clipboard-paste)

(defun wl-clipboard-paste ()
  "Paste from wl-clipboard"
  (shell-command-to-string "wl-paste --no-newline"))

;; Configure checkbox lists to evaluate recursively
(setq org-checkbox-hierarchical-statistics nil)

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
