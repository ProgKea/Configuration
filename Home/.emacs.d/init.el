(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org"   . "https://orgmode.org/elpa/")
                         ("elpa"  . "https://elpa.gnu.org/packages/")))
(package-initialize)

(require 'use-package)
(setq use-package-always-ensure t)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory ))
(when (file-exists-p custom-file)
  (load custom-file))

(define-key key-translation-map (kbd "ESC") (kbd "C-g"))

(add-to-list 'load-path (expand-file-name "packages-not-in-repositories" user-emacs-directory))

(use-package emacs
  :ensure nil
  :config
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (global-display-line-numbers-mode)
  :custom
  (inhibit-startup-screen t)
  (scroll-margin 8)
  (ring-bell-function 'ignore)
  (use-short-answers t)
  (display-line-numbers-type 'relative)
  (async-shell-command-display-buffer nil)

  (read-file-name-completion-ignore-case t)
  (read-buffer-completion-ignore-case t)
  (completion-ignore-case t)

  (make-backup-files nil)
  (create-lockfiles nil)
  (auto-save-default nil))

(use-package cc-mode
  :ensure nil
  :custom
  (c-default-style "linux")
  (c-basic-offset 2)
  :hook
  (c-mode . (lambda ()
              (setq-local comment-start "// ")
              (setq-local comment-end ""))))

(use-package compile
  :ensure nil
  :custom
  (compile-command "")
  (compilation-ask-about-save nil)
  (compilation-always-kill t))

(use-package dired
  :ensure nil
  :custom
  (dired-dwim-target t)
  (dired-auto-revert-buffer t))

(use-package evil
  :custom
  (evil-want-keybinding nil)
  (evil-undo-system 'undo-fu)
  :config
  (evil-mode 1)
  (evil-set-initial-state 'shell-command-mode 'normal)
  (setq evil-insert-state-cursor nil))

(use-package evil-goggles
  :custom
  (evil-goggles-duration 0.10)
  :config
  (evil-goggles-mode))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; Minibuffer Packages
(use-package vertico
  :config
  (vertico-mode))

(use-package orderless
  :custom
  (orderless-smart-case t)
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :config
  (marginalia-mode))

(use-package consult)

(use-package corfu
  :custom
  (corfu-auto-delay 0.2)
  (corfu-auto-prefix 1)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  :config
  (global-corfu-mode))

(use-package cape
  :hook (emacs-lisp-mode . (lambda () (add-to-list 'completion-at-point-functions #'cape-elisp-symbol)))
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

;; languages
(use-package rust-mode)

(use-package go-mode)

(use-package markdown-mode
  :mode ("\\.md\\'" . markdown-mode))

(use-package yaml-mode)

(use-package odin-mode
  :ensure nil)

(use-package eglot
  :after (rust-mode)
  :ensure nil
  :hook ((rust-mode . eglot-ensure)
	 (odin-mode . eglot-ensure)
	 (go-mode   . eglot-ensure)))

(use-package dumb-jump
  :hook (xref-backend-functions . dumb-jump-xref-activate)
  :custom
  (dumb-jump-force-searcher 'rg)
  (dumb-jump-selector 'completing-read))

(use-package magit)

(use-package projectile
  :config
  (projectile-mode))

(use-package which-key
  :custom
  (which-key-idle-delay 0.3)
  :config
  (which-key-mode))

(use-package undo-fu)

(use-package undo-fu-session
  :custom
  (undo-fu-session-incompatible-files '("/COMMIT_EDITMSG\\'" "/git-rebase-todo\\'"))
  :config
  (undo-fu-session-global-mode))

(use-package vundo
  :commands (vundo)
  :custom
  (vundo-compact-display t)
  (vundo-glyph-alist vundo-unicode-symbols))

(use-package smartparens
  :hook (lisp-data-mode . smartparens-strict-mode)
  :config
  (require 'smartparens-config))

(use-package evil-smartparens
  :after (evil smartparens)
  :hook (smartparens-mode . evil-smartparens-mode))

(use-package general
  :config
  (general-create-definer leader-def
    :states '(normal visual emacs)
    :keymaps 'override
    :prefix "SPC")

  (leader-def
    "w" 'save-buffer
    "g" 'magit
    "u" 'vundo)

  (leader-def
   :keymaps 'smartparens-mode-map
   "k"  '(:ignore t :which-key "lisp")
   "ks" '(sp-forward-slurp-sexp :which-key "slurp")
   "kb" '(sp-forward-barf-sexp :which-key "barf")
   "kw" '(sp-wrap-round :which-key "wrap ()")
   "ku" '(sp-unwrap-sexp :which-key "unwrap"))

  (general-def
    :states '(insert)
    "C-SPC" 'completion-at-point)

  (general-def
    :states '(normal visual insert)
    "C-u" 'evil-scroll-up
    "C-l" 'async-shell-command
    "C-j" 'recompile
    "C-k" 'compile
    "C-f" 'projectile-find-file
    "C-s" 'projectile-switch-project
    "C-ö" 'projectile-dired)

  (general-def
    :states '(visual)
    "gc" 'comment-dwim)

  (general-def
    :states '(normal)
    "g D" 'dumb-jump-go
    "<up>" 'previous-error
    "<down>" 'next-error
    "C-w C-j" 'evil-window-down
    "C-w C-k" 'evil-window-up
    "C-w C-h" 'evil-window-left
    "C-w C-l" 'evil-window-right
    "C-w C-q" 'evil-quit)

  (general-def
    :states '(normal)
    :keymaps 'eglot-mode-map

    "SPC f" 'eglot-format
    "SPC r" 'eglot-rename
    "SPC a" 'eglot-code-actions)

  (general-def
    :states '(normal insert visual)
    :keymaps 'override
    "C-a r" 'consult-ripgrep
    "C-a l" 'consult-line
    "C-a m" 'consult-kmacro
    "C-x b" 'consult-buffer))

(use-package gruber-darker-theme)
(use-package zenburn-theme)
