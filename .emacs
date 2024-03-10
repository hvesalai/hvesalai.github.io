;; For complex scala files
(setq max-lisp-eval-depth 50000)
(setq max-specpdl-size 5000)
(setq ring-bell-function 'ignore)

;; Put autosave files (ie #foo#) in one place, *not*
;; scattered all over the file system!
(defvar autosave-dir
 (concat "/home/" (user-login-name) "/tmp/emacs_autosaves/"))

(make-directory autosave-dir t)

(defun auto-save-file-name-p (filename)
  (string-match "^#.*#$" (file-name-nondirectory filename)))

(defun make-auto-save-file-name ()
  (concat autosave-dir
   (if buffer-file-name
      (concat "#" (file-name-nondirectory buffer-file-name) "#")
    (expand-file-name
     (concat "#%" (buffer-name) "#")))))

;; backed up in the corresponding directory. Emacs will mkdir it if necessary.)
(defvar backup-dir (concat "/home/" (user-login-name) "/tmp/emacs_backups/"))

(setq
 inhibit-startup-screen t
 create-lockfiles nil
 make-backup-files nil
 column-number-mode t
 scroll-error-top-bottom t
 show-paren-delay 0.5
 use-package-always-ensure t
 sentence-end-double-space nil
 menu-bar-mode -1
 column-number-mode t
 show-paren-mode t
 backup-directory-alist (list (cons "." backup-dir))
 truncate-partial-width-windows nil
  tramp-remote-path '(tramp-default-remote-path "/bin" "/usr/bin" "/sbin" "/usr/sbin" "/usr/local/bin" "/usr/local/sbin" "/local/bin" "/local/freeware/bin" "/local\
/gnu/bin" "/usr/freeware/bin" "/usr/pkg/bin" "/usr/contrib/bin" "/opt/bin" "/opt/sbin" "/opt/local/bin" tramp-own-remote-path)
  )

(setq-default
 indent-tabs-mode nil
 tab-width 8
 c-basic-offset 2
 js-indent-level 2
 next-line-add-newlines nil)

;; M-g == M-x goto-line, M-' = next-error
(global-set-key (kbd "M-g") 'goto-line)
(global-set-key (kbd "M-'") 'next-error)
(global-set-key (kbd "C-<next>") 'end-of-buffer)
(global-set-key (kbd "C-<prior>") 'beginning-of-buffer)

(add-hook 'scala-mode-hook '(lambda ()
  ;;  (require 'whitespace)
  (make-local-variable 'before-save-hook)
  ;; (add-hook 'before-save-hook 'whitespace-cleanup)
  ;;  (ensime-mode 1)
  (set (make-local-variable 'scala-mode:debug-messages) t)
  ;;(whitespace-mode)
;  (local-set-key (kbd "RET") 'newline-and-indent)
  (local-set-key (kbd "RET") '(lambda ()
                                (interactive)
                                (newline-and-indent)
                                (scala-indent:insert-asterisk-on-multiline-comment)))
  (local-set-key (kbd "M-RET") 'scala-indent:join-line)
  (local-set-key (kbd "<backtab>") 'scala-indent:indent-with-reluctant-strategy)
  (local-set-key (kbd "M-.") 'sbt-find-definitions)
  (local-set-key (kbd "C-x '") 'sbt-run-previous-command)
  (local-set-key (kbd "M-SPC") 'add-my-template)
))

(add-hook 'sbt-mode-hook '(lambda ()
  (setq compilation-scroll-output 'first-error)
  (setq compilation-skip-threshold 2)
  (setq comint-scroll-to-bottom-on-input nil)
  (local-set-key (kbd "C-a") 'comint-bol)
  (local-set-key (kbd "M-RET") 'comint-accumulate)
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)
))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(baud-rate 200000)
 '(frame-background-mode 'dark)
 '(grep-find-ignored-directories '(".git" "target"))
 '(grep-find-ignored-files '(".#*" "*~" "*.class" "*.jar"))
 '(package-selected-packages
   '(typescript-mode sbt-mode gh find-file-in-project use-package smartparens scala-mode gist diminish))
 '(sbt:default-command "Test/compile")
 '(sbt:program-name "/home/hvesalai/projects/trademarknow/tools/sbt.sh")
 '(sbt:program-options '("-MM"))
 '(sbt:scroll-to-bottom-on-output nil)
 '(scala-indent:align-parameters t)
 '(sp-autoinsert-pair nil)
 '(whitespace-style '(face tabs trailing)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(compilation-error ((t (:inherit error :foreground "brightcyan"))))
 '(compilation-warning ((t (:foreground "brightcyan"))))
 '(error ((t (:foreground "brightred" :weight bold))))
 '(warning ((t (:foreground "brightyellow")))))

(put 'downcase-region 'disabled nil)

(require 'package)
 ;: (add-to-list 'package-archives '("marmelade" . "http://marmalade-repo.org/") t)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(use-package scala-mode
  :interpreter
  ("scala" . scala-mode))
(use-package sbt-mode
  :commands sbt-start sbt-command
  :config
  ;; WORKAROUND: https://github.com/ensime/emacs-sbt-mode/issues/31
  ;; allows using SPACE when in the minibuffer
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map))

(setq my-templates
      '(implicit-execution-context "(implicit ec: ExecutionContext)" execution-context "ec: ExecutionContext" future-extensions "import com.onomatics.util.FutureSupport.FutureExtensions"))

(defun add-my-template (name)
  (interactive
   (list
    (completing-read "Insert template: "
                     (cl-loop for (key value) on my-templates by 'cddr
                              collect key))))
  (insert (plist-get my-templates (intern name))))


(define-derived-mode tabbed-mode text-mode "Tab separated mode"
  (local-set-key (kbd "TAB") 'self-insert-command))


(add-hook 'sbt-mode-hook (lambda ()
                           (setq prettify-symbols-alist
                                 `((,(expand-file-name (directory-file-name default-directory)) . ?⌂)
                                   (,(expand-file-name "~") . ?~)))
                                       (prettify-symbols-mode t)))
(progn
  (add-to-list 'auto-mode-alist
               '("\\.tsv" . tabbed-mode))
  (modify-coding-system-alist 'file "\\.tsv" 'utf-8))
(put 'upcase-region 'disabled nil)
