;;; trans.el --- Emacs frontend for <https://github.com/soimort/translate-shell>  -*- lexical-binding: t; -*-


;;; Commentary:
;;

;;; Code:

(require 'subr-x)

(defgroup trans nil
  "A Emacs frontend for <https://github.com/soimort/translate-shell>."
  :group 'tools
  :prefix "trans-")

(defcustom trans-command "trans"
  "Translate Shell command."
  :type 'string)

(defconst trans--buffer "*translate shell*")

(defvar trans--text-history '())

(defun trans--chinese-string-p (string)
  "Return Non-nil if STRING is a Chinese string."
  (string-match "[[:multibyte:]]" string))

(defun trans--1 (text &optional extra-options)
  (shell-command-to-string
   (format "%s %s %s %s"
           trans-command
           (cond ((trans--chinese-string-p text) "-s zh -t en")
                 ((or (string-match " " text) extra-options) "-s en -t zh")
                 (t "-t en"))
           (or extra-options "")
           (shell-quote-argument text))))

;;;###autoload
(defun trans-popup (text)
  "Entry point.  Diwpaly result in popup-tip."
  (interactive (list
                (or (when (use-region-p)
                      (buffer-substring
                       (region-beginning) (region-end)))
                    (thing-at-point 'word t))))
  (unless text (error "No useable text at point"))
  (unless (require 'popup nil t) (error "`popup' no avaiable"))
  (popup-tip
   (string-trim (trans--1 text "-b"))
   :margin t))

;;;###autoload
(defun trans-message (text)
  "Entry point.  Diwpaly result in echo area."
  (interactive (list
                (or (when (use-region-p)
                      (buffer-substring
                       (region-beginning) (region-end)))
                    (thing-at-point 'word t))))
  (unless text (error "No useable text at point"))
  (message (string-trim (trans--1 text "-b"))))

;;;###autoload
(defun trans (text)
  "Entry point.  Display result in buffer."
  (interactive (let* ((default
                        (or
                         (when (use-region-p)
                           (buffer-substring
                            (region-beginning) (region-end)))
                         (thing-at-point 'word t)))
                      (text
                       (read-string
                        (if default (format "Translate (default \"%s\"): " default)
                          "Translate: ")
                        nil 'trans--text-history default)))
                 (list text)))
  (with-current-buffer (get-buffer-create trans--buffer)
    (erase-buffer)
    (insert (trans--1 text))
    (require 'ansi-color)
    (ansi-color-apply-on-region (point-min) (point-max))
    (pop-to-buffer trans--buffer)))

(provide 'trans)
;;; trans.el ends here
