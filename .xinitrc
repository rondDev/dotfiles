!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

  # xrandr --output DP-2 --left-of DP-1
lxpolkit &

  #devilspie -a &

  #picom -b --animations --animation-window-mass 0.5 --animation-for-open-window zoom --animation-stiffness 350 &


  #xcompmgr &

  #xrandr --output DP-0 --off
  #xrandr --output DP-2 --off
  #xrandr --output DP-4 --off
xrandr --output DP-2 --mode 1920x1080 --rate 144 --left-of DP-4 --output DP-4 --mode 3440x1440 --rate 165 --output DP-0 --mode 3440x1440 --rate 99.98 --right-of DP-4
  #xrandr --output DP-2 --auto --left-of DP-4 --output DP-4 --auto --output DP-0 --auto --right-of DP-4
xrandr --dpi 94


feh --bg-fill /home/rond/Pictures/vaporwave.jpg
  # exec i3
screencloud &
  #dwmblocks &
keepassxc &
  #pasystray &
discord &
birdtray &
mattermost-desktop &
nohup jupyter notebook &
solaar -w hide &
  #exec dwm
exec xmonad
