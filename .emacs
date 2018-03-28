;;; package --- Summary
;;; Commentary:
;;; Code:

;; EMACS
(defvar ikke--file-name-handler-alist file-name-handler-alist)
(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6
      file-name-handler-alist nil)

(fset 'yes-or-no-p 'y-or-n-p)

(when window-system
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1))

(blink-cursor-mode 0)
(show-paren-mode 1)
(electric-pair-mode 1)
(global-hl-line-mode 1)
(global-linum-mode 1)
(global-prettify-symbols-mode 1)
(which-function-mode 1)
(recentf-mode 1)

(defconst .emacs-MAX_LINE_LENGTH 100)
(setq-default indent-tabs-mode nil
              tab-width 4
              recent-save-file "~/.emacs.d/recentf")
(setq inhibit-startup-message t
      linum-format " %3d"
      recentf-max-saved-items 8
      mouse-wheel-follow-mouse 't
      mouse-wheel-scroll-amount '(1 ((shift) . 1))
      mouse-wheel-progressive-speed nil
      ;;      scroll-conservately 10000
      ;;    scroll-step 1
      auto-window-vscroll nil)
(set-face-attribute 'default nil :height 105)
(add-to-list 'load-path "~/.emacs.d/libraries/")

;; BACKUP
(setq backup-directory-alist `(("." . "~/.emacs.d/backups")))
(setq make-backup-files t
      backup-by-copying t
      version-control t
      delete-old-versions t
      kept-old-versions 6
      kept-new-versions 9
      auto-save-default t
      auto-save-timeout 20
      auto-save-interval 200)

(defun move-line (n)
  "Move the current line up or down by N lines."
  (interactive "p")
  (setq col (current-column))
  (beginning-of-line) (setq start (point))
  (end-of-line) (forward-char) (setq end (point))
  (let ((line-text (delete-and-extract-region start end)))
    (forward-line n)
    (insert line-text)
    ;; restore point to original column in moved line
    (forward-line -1)
    (forward-char col)))

(defun move-line-up (n)
  "Move the current line up by N lines."
  (interactive "p")
  (move-line (if (null n) -1 (- n))))

(defun move-line-down (n)
  "Move the current line down by N lines."
  (interactive "p")
  (move-line (if (null n) 1 n)))

(global-set-key (kbd "M-<up>") 'move-line-up)
(global-set-key (kbd "M-<down>") 'move-line-down)

(advice-add 'load-theme :around '(lambda (orig-fun &rest args)
                                   (mapc #'disable-theme custom-enabled-themes)
                                   (apply orig-fun args)
                                   (setq linum-format " %3d")
                                   (spaceline-compile)))

;; REPOS
(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  (add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives '("gnu" . (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)

;; USE-PACKAGE
(if (not (package-installed-p 'use-package))
    (progn
      ;;      (package-refresh-contents)
      (package-install 'use-package)))
(eval-when-compile (require 'use-package))

(use-package solarized-theme
  :ensure t
  :after (spaceline)
  :config
  (setq x-underline-at-descent-line t)
  (setq solarized-high-contrast-mode-line nil)
  (setq solarized-distinct-fringe-background nil)
  (defun ikke--solarized ()
    (setq linum-format " %2d ")
    (spaceline-compile))
  (defun solarized-dark ()
    (interactive)
    (load-theme 'solarized-dark t)
    (set-face-attribute 'linum nil :foreground "#425257")
    (set-face-attribute 'mode-line nil :underline "#073642" :box "#073642")
    (set-face-attribute 'mode-line-inactive nil :underline "#073642" :box "#073642")
    (ikke--solarized))
  (defun solarized-light ()
    (interactive)
    (load-theme 'solarized-light t)
    (set-face-attribute 'mode-line nil :underline "#eee8d5" :box "#eee8d5")
    (set-face-attribute 'mode-line-inactive nil :underline "#eee8d5" :box "#eee8d5")
    (ikke--solarized))
  (solarized-dark))

(use-package spacemacs-common
  :ensure spacemacs-theme)

(use-package github-theme
  :ensure t)

(use-package color-theme-sanityinc-tomorrow
  :ensure t)

(use-package base16-theme
  :ensure t)

(use-package evil
  :ensure t)

(use-package smooth-scrolling
  :ensure t
  :config
  (require 'smooth-scrolling)
  (smooth-scrolling-mode 1))

(use-package dimmer
  :ensure t
  :config
  (setq dimmer-fraction 0.2))

;; Hides minor modes
(use-package diminish
  :ensure t
  :config
  (add-hook 'highlight-indentation-mode-hook '(lambda () (diminish 'highlight-indentation-mode)))
  (add-hook 'auto-revert-mode-hook '(lambda () (diminish 'auto-revert-mode))))

(use-package rainbow-delimiters
  :ensure t
  :hook
  ((prog-mode . rainbow-delimiters-mode)))

(use-package which-key
  :ensure t
  :after (diminish)
  :config
  (which-key-mode)
  (diminish 'which-key-mode))

;; Selection narrowing down tool
(use-package helm
  :ensure t
  :config
  (global-set-key (kbd "M-x") 'helm-M-x)
  (helm-autoresize-mode 1)
  (setq helm-split-window-inside-p t
        helm-ff-file-name-history-use-recentf t
        helm-buffers-fuzzy-matching t
        helm-projectile-fuzzy-match t
        helm-locate-fuzzy-match t
        helm-M-x-fuzzy-match t
        helm-imenu-fuzzy-match t
        helm-apropos-fuzzy-match t
        helm-lisp-fuzzy-completion t
        helm-session-fuzzy-match t
        helm-etags-fuzzy-match t
        helm-mode-fuzzy-match t
        helm-completion-in-region-fuzzy-match t)
  (global-set-key (kbd "C-x b") 'helm-mini)
  (global-set-key (kbd "M-y") 'helm-show-kill-ring)
  (global-set-key (kbd "C-x C-f") 'helm-find-files)
  (global-set-key (kbd "C-x r b") 'helm-bookmarks))

(use-package helm-fuzzier
  :ensure t
  :after (helm)
  :config
  (helm-fuzzier-mode 1))

(use-package helm-flx
  :ensure t
  :config
  (helm-flx-mode +1)
  (setq helm-flx-for-helm-locate t))

;; Search narrowing down tool
(use-package helm-swoop
  :ensure t
  :after (helm)
  :config
  (global-set-key (kbd "C-s") 'helm-swoop))

;; Easily switch between windows
(use-package ace-window
  :ensure t
  :config
  (global-set-key (kbd "M-p") 'ace-window))

(use-package multiple-cursors
  :ensure t
  :config
  (global-set-key (kbd "C-c m") 'mc/edit-lines))

;; Git integration
(use-package magit
  :ensure t
  :config
  (global-set-key (kbd "C-c g") 'magit-status))

;; Dockerfile support
(use-package dockerfile-mode
  :ensure t)

;;Modeline replacement
(use-package spaceline
  :ensure t
  :config
  (require 'spaceline-config)
  (spaceline-helm-mode 1)
  (spaceline-spacemacs-theme)
  (spaceline-toggle-buffer-encoding-abbrev-off)) 

(use-package all-the-icons
  :ensure t)

;; Shows hex color code colors
(use-package rainbow-mode
  :ensure t)

;; Project management
(use-package projectile
  :ensure t
  :config
  (projectile-mode))

(use-package helm-projectile
  :ensure t
  :after (helm projectile)
  :config
  (define-key projectile-mode-map (kbd "C-c p p") 'helm-projectile-switch-project)
  (define-key projectile-mode-map (kbd "C-c p f") 'helm-projectile-find-file))

;; Extra C/C++ support
(use-package irony
  :ensure t
  :hook
  ((c-mode . irony-mode)
   (c++-mode . irony-mode)
   (irony-mode . irony-cdb-autosetup-compile-options)))

;; Syntax check
(use-package flycheck
  :ensure t
  :after (diminish)
  :config
  (global-flycheck-mode)
  (setq flycheck-flake8-maximum-line-length .emacs-MAX_LINE_LENGTH)
  (diminish 'flycheck-mode))

(use-package helm-flycheck
  :ensure t
  :after (helm flycheck)
  :config
  (require 'helm-flycheck)
  (define-key flycheck-mode-map (kbd "C-c ! h") 'helm-flycheck))

;; Irony backend for flycheck
(use-package flycheck-irony
  :ensure t
  :after (irony flycheck)
  :config
  (add-hook 'flycheck-mode #'flycheck-irony-setup))

;; Irony backend for eldoc (function definition display)
(use-package irony-eldoc
  :ensure t
  :after (irony eldoc)
  :config
  (add-hook 'irony-mode-hook #'irony-eldoc))

;; Auto-complete 
(use-package company
  :ensure t
  :after (diminish)
  :config
  (global-company-mode)
  (setq company-idle-delay 0
        company-minimum-prefix-length 1)
  (define-key company-active-map (kbd "M-n") nil)
  (define-key company-active-map (kbd "M-p") nil)
  (define-key company-active-map (kbd "C-n") 'company-select-next)
  (define-key company-active-map (kbd "C-p") 'company-select-previous)
  (diminish 'company-mode))

;; Fuzzy matching for company
(use-package company-flx
  :ensure t
  :after (company)
  :config
  (with-eval-after-load 'company
    (company-flx-mode +1)))

;; Irony backend for company
(use-package company-irony
  :ensure t
  :after (irony company company-irony-c-headers)
  :config
  (add-to-list 'company-backends 'company-irony))

;; C Header completion backend
(use-package company-irony-c-headers
  :ensure t
  :after (company irony)
  :config
  (add-to-list 'company-backends 'company-irony-c-headers))

;; Display flycheck errors in popup-tip
(use-package flycheck-popup-tip
  :ensure t
  :after (flycheck)
  :hook
  ((flycheck-mode . flycheck-popup-tip-mode)))

;; Display company results with helm
(use-package helm-company
  :ensure t
  :after (helm company)
  :config
  (define-key company-active-map (kbd "C-s") 'helm-company))

;; Snippets support
(use-package yasnippet
  :ensure t
  :after (diminish)
  :config
  (yas-global-mode 1)
  (diminish 'yasnippet-mode))

;; Snippets
(use-package yasnippet-snippets
  :ensure t
  :after (yasnippet))

;; Show snippets with helm
(use-package helm-c-yasnippet
  :ensure t
  :after (yasnippet helm)
  :config
  (setq helm-yas-space-match-any-greedy t)
  (global-set-key (kbd "C-c y") 'helm-yas-complete))

;; Python syntax formatter
(use-package py-autopep8
  :ensure t)

;; Python IDE Features (completion, syntax check, documentation, refactoring, ...)
(use-package elpy
  :ensure t
  :after (py-autopep8 diminish)
  :config 
  (elpy-enable)
  (pyvenv-workon 3)
  (define-key yas-minor-mode-map (kbd "C-c k") 'yas-expand)
  (setq elpy-rpc-backend "jedi"
        eldoc-idle-delay 1)
  (remove-hook 'elpy-modules 'elpy-module-flymake)
  (remove-hook 'elpy-modules 'elpy-module-highlight-indentation)
  (add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)
  (diminish 'elpy-mode))

;; Indentation formatter
(use-package aggressive-indent
  :ensure t
  :after (diminish)
  :config
  (global-aggressive-indent-mode 1)
  (diminish 'aggressive-indent-mode))

;; Markdown support
(use-package markdown-mode
  :ensure t
  :config
  (setq markdown-open-command 'markdown
        markdown-css-paths (list "https://unpkg.com/sakura.css/css/sakura.css"))
  (define-key markdown-mode-map (kbd "M-p") 'ace-window))

;; Browser preview of markdown
(use-package markdown-preview-mode
  :ensure t
  :after (markdown-mode)
  :config
  (setq markdown-preview-stylesheets (list "https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/2.10.0/github-markdown.min.css")))

;; Displays a line to indicate when you lines are too long
;; (use-package fill-column-indicator
;;   :ensure t
;;   :after (diminish company)
;;   :hook
;;   ((prog-mode . fci-mode))
;;   :config
;;   (setq-default fill-column .emacs-MAX_LINE_LENGTH
;;                 fci-rule-color "#073642")
;;   (diminish 'fci-mode)
;;   (defvar-local company-fci-mode-on-p nil)
;;   (defun company-turn-off-fci (&rest ignore)
;;     (when (boundp 'fci-mode)
;;       (setq company-fci-mode-on-p fci-mode)
;;       (when fci-mode (fci-mode -1))))
;;   (defun company-maybe-turn-on-fci (&rest ignore)
;;     (when company-fci-mode-on-p (fci-mode 1)))
;;   (add-hook 'company-completion-started-hook 'company-turn-off-fci)
;;   (add-hook 'company-completion-finished-hook 'company-maybe-turn-on-fci)
;;   (add-hook 'company-completion-cancelled-hook 'company-maybe-turn-on-fci))

(require 'column-marker)
(add-hook 'prog-mode-hook (lambda () (interactive) (column-marker-1 .emacs-MAX_LINE_LENGTH)))

;; Plantuml support
(use-package plantuml-mode
  :ensure t
  :config
  (setq plantuml-jar-path "/opt/plantuml/plantuml.jar")
  (add-to-list 'auto-mode-alist '("\\.plantuml\\'" . plantuml-mode)))

(use-package highlight-indent-guides
  :ensure t
  ;; :hook
  ;; (prog-mode . highlight-indent-guides-mode)
  :config
  (setq highlight-indent-guides-method 'character))

(use-package neotree
  :ensure t
  :after (all-the-icons)
  :config
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow))
  ;;        projectile-switch-project-action 'neotree-projectile-action)
  (defun neotree-project-dir ()
    "Open NeoTree using the git root."
    (interactive)
    (let ((project-dir (projectile-project-root))
          (file-name (buffer-file-name)))
      (neotree-toggle)
      (if project-dir
          (if (neo-global--window-exists-p)
              (progn
                (neotree-dir project-dir)
                (neotree-find file-name)))
        (message "Could not find git project root."))))
  (global-set-key [f8] 'neotree-project-dir))

;; LANGUAGES
;; C
(setq c-default-style "linux"
      c-basic-offset 4)

;; PYTHON
(setq python-indent-offset 4)

(add-hook 'emacs-startup-hook
          (lambda ()(setq gc-cons-threshold 20000000
                     gc-cons-percentage 0.1
                     file-name-handler-alist ikke--file-name-handler-alist)))

(provide '.emacs)
;;; .emacs ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-term-color-vector
   [unspecified "#2b303b" "#bf616a" "#a3be8c" "#ebcb8b" "#8fa1b3" "#b48ead" "#8fa1b3" "#c0c5ce"])
 '(compilation-message-face (quote default))
 '(cua-global-mark-cursor-color "#2aa198")
 '(cua-normal-cursor-color "#839496")
 '(cua-overwrite-cursor-color "#b58900")
 '(cua-read-only-cursor-color "#859900")
 '(custom-safe-themes
   (quote
    ("e11569fd7e31321a33358ee4b232c2d3cf05caccd90f896e1df6cab228191109" "3b5ce826b9c9f455b7c4c8bff22c020779383a12f2f57bf2eb25139244bb7290" "2a998a3b66a0a6068bcb8b53cd3b519d230dd1527b07232e54c8b9d84061d48d" "f0c98535db38af17e81e491a77251e198241346306a90c25eb982b57e687d7c0" "c968804189e0fc963c641f5c9ad64bca431d41af2fb7e1d01a2a6666376f819c" "16dd114a84d0aeccc5ad6fd64752a11ea2e841e3853234f19dc02a7b91f5d661" "3380a2766cf0590d50d6366c5a91e976bdc3c413df963a0ab9952314b4577299" "78c1c89192e172436dbf892bd90562bc89e2cc3811b5f9506226e735a953a9c6" default)))
 '(dimmer-mode t nil (dimmer))
 '(highlight-changes-colors (quote ("#d33682" "#6c71c4")))
 '(highlight-symbol-colors
   (--map
    (solarized-color-blend it "#002b36" 0.25)
    (quote
     ("#b58900" "#2aa198" "#dc322f" "#6c71c4" "#859900" "#cb4b16" "#268bd2"))))
 '(highlight-symbol-foreground-color "#93a1a1")
 '(highlight-tail-colors
   (quote
    (("#073642" . 0)
     ("#546E00" . 20)
     ("#00736F" . 30)
     ("#00629D" . 50)
     ("#7B6000" . 60)
     ("#8B2C02" . 70)
     ("#93115C" . 85)
     ("#073642" . 100))))
 '(hl-bg-colors
   (quote
    ("#7B6000" "#8B2C02" "#990A1B" "#93115C" "#3F4D91" "#00629D" "#00736F" "#546E00")))
 '(hl-fg-colors
   (quote
    ("#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36")))
 '(hl-paren-colors (quote ("#2aa198" "#b58900" "#268bd2" "#6c71c4" "#859900")))
 '(magit-diff-use-overlays nil)
 '(package-selected-packages
   (quote
    (company-flx helm-flx helm-fuzzier zenburn-theme yasnippet-snippets which-key use-package sublimity spacemacs-theme spaceline solarized-theme smooth-scrolling rebecca-theme rainbow-mode rainbow-delimiters py-autopep8 plantuml-mode neotree multiple-cursors monokai-theme markdown-preview-mode magit irony-eldoc highlight-indent-guides helm-swoop helm-projectile helm-flycheck helm-company helm-c-yasnippet github-theme focus flycheck-popup-tip flycheck-irony fill-column-indicator evil elpy dockerfile-mode dimmer diminish company-quickhelp company-irony-c-headers company-irony color-theme-sanityinc-tomorrow color-theme circadian base16-theme all-the-icons aggressive-indent ace-window)))
 '(pos-tip-background-color "#073642")
 '(pos-tip-foreground-color "#93a1a1")
 '(smartrep-mode-line-active-bg (solarized-color-blend "#859900" "#073642" 0.2))
 '(term-default-bg-color "#002b36")
 '(term-default-fg-color "#839496")
 '(vc-annotate-background-mode nil)
 '(weechat-color-list
   (quote
    (unspecified "#002b36" "#073642" "#990A1B" "#dc322f" "#546E00" "#859900" "#7B6000" "#b58900" "#00629D" "#268bd2" "#93115C" "#d33682" "#00736F" "#2aa198" "#839496" "#657b83")))
 '(xterm-color-names
   ["#073642" "#dc322f" "#859900" "#b58900" "#268bd2" "#d33682" "#2aa198" "#eee8d5"])
 '(xterm-color-names-bright
   ["#002b36" "#cb4b16" "#586e75" "#657b83" "#839496" "#6c71c4" "#93a1a1" "#fdf6e3"]))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
