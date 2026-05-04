;; base16-eldritch-theme.el -- A base16 colorscheme

;;; Commentary:
;; Base16: (https://github.com/tinted-theming/home)

;;; Authors:
;; Scheme: Jan T. Sott (http://github.com/idleberg)
;; Template: Kaleb Elwert <belak@coded.io>

;;; Code:

(require 'base16-theme)

(defvar base16-eldritch-theme-colors
  '(:base00 "#212337"
    :base01 "#21222c"
    :base02 "#4a4543"
    :base03 "#7081d0"
    :base04 "#ebfafa"
    :base05 "#a5a2a2"
    :base06 "#ebfafa"
    :base07 "#f7f7f7"
    :base08 "#04d1f9"
    :base09 "#e8bbd0"
    :base0A "#f9515d"
    :base0B "#9071f4"
    :base0C "#f265b5"
    :base0D "#37f499"
    :base0E "#f16c75"
    :base0F "#f1fc79")
  "All colors for Base16 eldritch are defined here.")

;; Define the theme
(deftheme base16-eldritch)

;; Add all the faces to the theme
(base16-theme-define 'base16-eldritch base16-eldritch-theme-colors)

;; Mark the theme as provided
(provide-theme 'base16-eldritch)

(provide 'base16-eldritch-theme)

;;; base16-3024-theme.el ends here
