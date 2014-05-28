;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; File name: ` ~/.emacs '
;;; ---------------------
;;;
;;; If you need your own personal ~/.emacs
;;; please make a copy of this file
;;; an placein your changes and/or extension.
;;;
;;; Copyright (c) 1997-2002 SuSE Gmbh Nuernberg, Germany.
;;;
;;; Author: Werner Fink, <feedback@suse.de> 1997,98,99,2002
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Test of Emacs derivates
;;; -----------------------
(if (string-match "XEmacs\\|Lucid" emacs-version)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; XEmacs
  ;;; ------
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (progn
     (if (file-readable-p "~/.xemacs/init.el")
        (load "~/.xemacs/init.el" nil t))
  )
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; GNU-Emacs
  ;;; ---------
  ;;; load ~/.gnu-emacs or, if not exists /etc/skel/.gnu-emacs
  ;;; For a description and the settings see /etc/skel/.gnu-emacs
  ;;;   ... for your private ~/.gnu-emacs your are on your one.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (if (file-readable-p "~/.gnu-emacs")
      (load "~/.gnu-emacs" nil t)
    (if (file-readable-p "/etc/skel/.gnu-emacs")
	(load "/etc/skel/.gnu-emacs" nil t)))

  ;; Custum Settings
  ;; ===============
  ;; To avoid any trouble with the customization system of GNU emacs
  ;; we set the default file ~/.gnu-emacs-custom
  (setq custom-file "~/.gnu-emacs-custom")
  (load "~/.gnu-emacs-custom" t t)
;;;
)
;;;


;;; FROM HERE ON WE CAN FIND CODE ADDED BY EPL

;;----------------------------------------------------------
;; ASSOCIATE FILE EXTENSIONS WITH EMACS MODES
;;----------------------------------------------------------

(setq auto-mode-alist
      '(("\\.txt$" . text-mode)
        ("\\.tex$" . latex-mode)
        ("\\.Rnw$" . latex-mode)
        ("\\.texinfo$" . texinfo-mode)
        ("\\.h$" . c-mode)
        ("\\.c$" . c-mode)
        ("^/tmp/Re" . non-saved-text-mode)
        ("\\.lsp$" . lisp-mode)
        ("\\.S$" . S-mode)
        ("\\.R$" . R-mode)
        ("\\.r$" . R-mode)
        ("\\.py$" . python-mode)
        ("/\\..*emacs" . emacs-lisp-mode)
        ("\\.el$" . emacs-lisp-mode)
        ("\\.sh$" . shell-script-mode)
        ("\\.html$" . html-mode)
        ("\\.htm$" . html-mode)))

;;----------------------------------------------------------
;; R MODE
;;----------------------------------------------------------

(autoload 'R-mode "ess-site" "Emacs Speaks Statistics" t)
(load "/soft/ess-12.09-2/lisp/ess-site.el")

;; (defun my-start-R ()
;;   "Split window in 2, start R and load R-mode"
;;   (interactive)
;;   (R)
;;   (setq win1 (selected-window))
;;   (setq win2 (split-window-horizontally))
;; ;;  (setq win1 (split-window-vertically))
;; ;;  (select-window win2)
;;   (select-window win1)
;; )

(setq ess-ask-for-ess-directory nil)
(setq ess-local-process-name "R")
(setq ansi-color-for-comint-mode 'filter)
(setq comint-scroll-to-bottom-on-input t)
(setq comint-scroll-to-bottom-on-output t)
(setq comint-move-point-for-output t)
(defun my-ess-start-R ()
  (interactive)
  (if (not (member "*R*" (mapcar (function buffer-name) (buffer-list))))
      (progn
        (delete-other-windows)
        (setq w1 (selected-window))
        (setq w1name (buffer-name))
        (setq w2 (split-window w1 nil t))
        (R)
        (set-window-buffer w2 "*R*")
        (set-window-buffer w1 w1name)
  )))
(local-set-key (kbd "C-c C-r") 'my-ess-start-R)

;; ESS Mode (.R file)
(define-key ess-mode-map "\C-l" 'ess-eval-line)
(define-key ess-mode-map "\C-p" 'ess-eval-function-or-paragraph)
(define-key ess-mode-map "\C-r" 'ess-eval-region)

;;----------------------------------------------------------
;; Run gdb on R
;;----------------------------------------------------------
;; Rgdb starts gdb with R. New buffer is not of mode ess, so usual ess-eval functions don't work
;; send-line, send-paragraph and send-region are a simpler version of ess-evals that do work

(defun Rgdb ()
  "Start R with gdb"
  (interactive)
  (R-mode)              ;put original window in R-mode
  (let ((name "R -d gdb"))(gdb name))
)

(defun send-line () 
  (interactive)
  (save-excursion
    (beginning-of-line)
    (if (not (= (point) (point-max)))
      (let ((linestr (buffer-substring (progn (end-of-line) (point)) (progn (beginning-of-line) (point)))))
      (other-window 1)
      (end-of-buffer)
      (insert linestr)
      (call-interactively (key-binding "\r"))
      (other-window -1)
      )
    )
  )
)

(defun send-paragraph (&optional arg)
  (interactive "P")
  (let ((beg (progn (backward-paragraph 1) (point)))
  (end (progn (forward-paragraph arg) (point))))
  (copy-region-as-kill beg end))
  (other-window 1)
  (end-of-buffer)
  (yank)
  (call-interactively (key-binding "\r"))
  (other-window -1)
)

(defun send-region (beg end &optional args)   ;beg and end indicate beginning and end of selection
  (interactive "r\nP")                        ;r\nP is needed so that beg, end are properly set up
  (copy-region-as-kill beg end)
  (other-window 1)
  (end-of-buffer)
  (yank)
  (call-interactively (key-binding "\r"))
  (other-window -1)
)

(global-set-key (kbd "C-c l") 'send-line) 
(global-set-key (kbd "C-c p") 'send-paragraph) 
(global-set-key (kbd "C-c r") 'send-region)

;;----------------------------------------------------------
;; Python MODE
;;----------------------------------------------------------

; python-mode
(setq py-install-directory "~/.emacs.d/python-mode.el-6.1.3")
(add-to-list 'load-path py-install-directory)
(require 'python-mode)

; use IPython
(setq-default py-shell-name "ipython")
(setq-default py-which-bufname "IPython")
; use the wx backend, for both mayavi and matplotlib
(setq py-python-command-args
  '("--gui=wx" "--pylab=wx" "-colors" "Linux"))
(setq py-force-py-shell-name-p t)

; switch to the interpreter after executing code
(setq py-shell-switch-buffers-on-execute-p t)
;; (setq py-switch-buffers-on-execute-p t)
; don't split windows
;; (setq py-split-windows-on-execute-p nil)
; try to automagically figure out indentation
(setq py-smart-indentation t)

;;;----------------------------------------------------------
;;; TEX MODE auc-tex
;;;----------------------------------------------------------

(autoload 'LaTeX-mode "tex-site"  "Math mode for TeX." t)
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(add-hook 'LaTeX-mode-hook 'reftex-mode)

(setq-default abbrev-mode t)
(load "/Users/eplanet/.emacsinputs/latexinit.el")
(read-abbrev-file "/Users/eplanet/.emacsinputs/abbrevs.el")

(load "/Users/eplanet/.emacsinputs/flyspell-1.7m.el")
(autoload 'flyspell-mode "flyspell" "On-the-fly spelling checker." t)
(autoload 'flyspell-delay-command "flyspell" "Delay on command." t) 
(autoload 'tex-mode-flyspell-verify "flyspell" "" t)
(global-set-key "\C-i" 'flyspell-buffer) ;mark spelling errors across buffer

;;----------------------------------------------------------
;; UTILITIES
;;----------------------------------------------------------

(defun newlatex()
  (interactive)
  (insert-file "/Users/eplanet/.emacsinputs/paper.tex"))

(defun newletter()
  (interactive)
  (insert-file "/Users/eplanet/.emacsinputs/letter.tex"))

(defun newfax()
  (interactive)
  (insert-file "/Users/eplanet/.emacsinputs/fax.tex"))

(defun newpres()
  (interactive)
  (insert-file "/Users/eplanet/.emacsinputs/pres.tex"))

(defun newrprog()
  (interactive)
  (insert-file "/Users/eplanet/.emacsinputs/rprogram.r"))

(defun bioclib()
  (interactive)
  (insert-file "/Users/eplanet/.emacsinputs/biocliblist.txt"))

(defun newrweave()
  (interactive)
  (insert-file "/Users/eplanet/.emacsinputs/rweavedoc.Rnw"))

;set properties of new frames
;(smart-frame-positioning-mode nil)

;;----------------------------------------------------------
;; EPLANET ADDONS
;;----------------------------------------------------------

(transient-mark-mode t)
(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)

;;turn auto indent to off
;;(add-hook 'TeX-mode-hook 
;;  '(lambda () (auto-fill-mode -1))) 

;; do not make backup files
(setq make-backup-files nil)

;; Changes all yes/no questions to y/n type
(fset 'yes-or-no-p 'y-or-n-p)

;;Keep mouse high-lightening 
(setq mouse-sel-retain-highlight t)

;;set cursor color to red
(set-cursor-color "red")
 
;;set cursor not to blink
(blink-cursor-mode 0)
 
;;highlight current line
;(global-hl-line-mode 1)
;(set-face-background 'hl-line "light yellow")
 
;;show position line position
(column-number-mode 1)
 
;;full screen
;(defun toggle-fullscreen () (interactive) (set-frame-parameter nil 'fullscreen (if (frame-parameter nil 'fullscreen) nil 'fullboth)))
;(global-set-key [(meta return)] 'toggle-fullscreen)

;resize frames
;(global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
;(global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
;(global-set-key (kbd "C-") 'shrink-window)
;(global-set-key ("\^[[5C") 'enlarge-window)

;; ;share clipboard with OSX
;; (defun copy-from-osx ()
;;   (shell-command-to-string "pbpaste"))
;; (defun paste-to-osx (text &optional push)
;;   (let ((process-connection-type nil)) 
;;       (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
;;         (process-send-string proc text)
;;         (process-send-eof proc))))
;; (setq interprogram-cut-function 'paste-to-osx)
;; (setq interprogram-paste-function 'copy-from-osx)

;; Remove splash screen
(setq inhibit-splash-screen t)

;;turn off auto save
(setq auto-save-default nil) 
(setq transient-mark-mode t)

;; Set default window size
(setq initial-frame-alist
      '((top . 20) (left . 10)
        (width . 150) (height . 55)
;;        (font . "-apple-monaco-medium-r-normal--13-140-72-72-m-140-iso10646-1")))
        (font . "-apple-monaco-medium-r-normal--12-140-72-72-m-140-iso10646-1")))
;;        (font . "-apple-monaco-medium-r-normal--11-140-72-72-m-140-iso10646-1")))
;;        (font . "-apple-courier-medium-r-normal--12-120-72-72-m-120-mac-roman")))

;;pdf mode in tex 
(setq-default TeX-PDF-mode t)

;; disable bell
;;(setq visible-bell t)

;;full screen
(defun toggle-fullscreen () (interactive) (set-frame-parameter nil 'fullscreen (if (frame-parameter nil 'fullscreen) nil 'fullboth)))
(global-set-key [(meta return)] 'toggle-fullscreen)

;;column mode
(cua-mode t)
(setq cua-enable-cua-keys nil)

;;hide tool bar (menu with buttons)
(custom-set-variables '(tool-bar-mode nil))

;;recenter
(global-set-key "\C-t" 'recenter)

;;auto indent (in latex mode)
(add-hook 'LaTeX-mode-hook 'auto-fill-mode)

;;do not auto indent comments when pressing return
(setq ess-fancy-comments nil)

;;move up with C-u (C-p is ised for R)
(global-set-key "\^u" 'previous-line)

;;add no-easy-keys (disables arrow, end, home and delete keys, as well as their control and meta prefixes. When using any of these keys, you instead get a message informing you of the proper Emacs shortcut you should use instead)
(load "/Users/eplanet/.emacsinputs/no-easy-keys.el")
(require 'no-easy-keys)
(no-easy-keys 1)

;;;;force window split to horizontal
;;(setq split-width-threshold 1)

;;emacs checks if colour scheme is dark or light before assigning colours
(let ((frame-background-mode 'light)) (frame-set-background-mode nil))

;;tell path to ispell
(setq ispell-program-name "/usr/local/Cellar/ispell/3.3.02/bin/ispell")

;;add this for emacs to see pdflatex
(getenv "PATH")
 (setenv "PATH"
(concat
 "/usr/texbin" ":"
(getenv "PATH")))

;;add auto-complete
(add-to-list 'load-path "~/.emacs.d/auto-complete-1.3.1")
(require 'auto-complete)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
(require 'auto-complete-config)
(ac-config-default)
(global-auto-complete-mode t)

;;vertical line at position 80
(add-to-list 'load-path "~/.emacs.d/fill-column-indicator-1.83")
(require 'fill-column-indicator)
(define-globalized-minor-mode
 global-fci-mode fci-mode (lambda () (fci-mode 1)))
(global-fci-mode t)

;;ido stands for interactively do things. It makes switching between buffers, opening/closing files, etc., extremely easy to do
(require 'ido)
(ido-mode t)

;;shortcut for comment/uncomment
;; from http://www.opensubscriber.com/message/emacs-devel@gnu.org/10971693.html
(defun comment-dwim-line (&optional arg)
  "Replacement for the comment-dwim command.
        If no region is selected and current line is not blank and we are not at the end of the line,
        then comment current line.
        Replaces default behaviour of comment-dwim, when it inserts comment at the end of the line."
  (interactive "*P")
  (comment-normalize-vars)
  (if (and (not (region-active-p)) (not (looking-at "[ \t]*$")))
      (comment-or-uncomment-region (line-beginning-position) (line-end-position))
    (comment-dwim arg)))
(global-set-key "\M-;" 'comment-dwim-line)
