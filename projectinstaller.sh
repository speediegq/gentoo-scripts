#!/bin/bash
#
#                         _ _      _
# ___ _ __   ___  ___  __| (_) ___( )___
#/ __| '_ \ / _ \/ _ \/ _` | |/ _ \// __|
#\__ \ |_) |  __/  __/ (_| | |  __/ \__ \
#|___/ .__/ \___|\___|\__,_|_|\___| |___/
#    |_|
#                  __ _                       _   _
#  ___ ___  _ __  / _(_) __ _ _   _ _ __ __ _| |_(_) ___  _ __  ___
# / __/ _ \| '_ \| |_| |/ _` | | | | '__/ _` | __| |/ _ \| '_ \/ __|
#| (_| (_) | | | |  _| | (_| | |_| | | | (_| | |_| | (_) | | | \__ \
# \___\___/|_| |_|_| |_|\__, |\__,_|_|  \__,_|\__|_|\___/|_| |_|___/
#                     |___/ version whatever
#
#####################################################################
# _   _                        _    __
#| |_(_)_ __  _   _ _   _ _ __| |  / /
#| __| | '_ \| | | | | | | '__| | / /
#| |_| | | | | |_| | |_| | |  | |/ /
# \__|_|_| |_|\__, |\__,_|_|  |_/_/
#             |___/
#
#               _                  __ _
# ___ _ __   __| | ___ ___  _ __  / _(_) __ _
#/ __| '_ \ / _` |/ __/ _ \| '_ \| |_| |/ _` |
#\__ \ |_) | (_| | (_| (_) | | | |  _| | (_| |
#|___/ .__/ \__,_|\___\___/|_| |_|_| |_|\__, |
#    |_|                                |___/
#
#####################################################################

keychron=false # Enable keychron keyboard support in Linux (editing .xinitrc)

# Check if the user is based and is using Gentoo Linux (or distros based on it)
if [ -f "/etc/portage/make.conf" ]; then
    echo "You're using Gentoo Linux. That's based!" && gentoo=true
else 
    echo "This script has not been tested on any OS other than Gentoo. You're on your own if the script doesn't work. Why aren't you using such a based OS anyway?" && gentoo=false
fi

# Check if the user is using sudo or doas
if [ -f "/etc/doas.conf" ]; then
    perms=doas
else 
    perms=sudo
fi

[ "$(whoami)" != "root" ] && perms=echo && # Rather dumb way of doing it but itworks I suppose!
[ "$(whoami)" != "root" ] && emerge --noreplace doas # Install doas if not present and you're logged in as root!

# perms=doas # Uncomment and edit to override, in most cases not necessary.
giturl=https://tinyurl.com/spdconfig # Change this if the original link is down but you have a mirror

# Check if git (required to clone the repo) is present. And on Gentoo Linux, offer to install it for you.
if [ -f "/usr/bin/git" ]; then
	echo "Git is installed, great!"
else
    [ "$Gentoo" = "true" ] && $perms --noreplace dev-vcs/git && "echo Git installed as it was not present"
fi

echo "Using $perms, is this correct?" && sleep 1 # Nicely inform the user that they may want to edit the file
echo "This bash script will git clone $giturl and apply every configuration available!"
echo "It has only been tested with Gentoo but should work with other distros (although some features will be missing)"
echo "If you are not on Gentoo or other distros that use Portage, please install the packages manually"
echo "You should install: Picom fontawesome firefox feh Alacritty doas xclip"

# Git clone $giturl
$perms git clone $giturl && cd spdconfig && echo "Successfully cloned repository! (Using $perms)"

echo "Successfully changed directory" # Changed directory successfully!
echo "Copying .config" && cd .config && $perms cp -r * ~/.config && echo "Successfully copied files from .config (repo)"

# cd into the slstatus directory
cd slstatus

# Compile slstatus
echo "Compiling slstatus" && cd slstatus && rm slstatus && make && echo "slstatus compiled successfully"

# Check if a binary was created
if [ -f "~/.config/slstatus/slstatus" ]; then
	echo "~/.config/slstatus/slstatus &" >> ~/.xinitrc
else
	echo "slstatus failed to compile.. Sorry!"
fi

# Emerge picom (If the OS is Gentoo)
[ "$gentoo" = "true" ] && echo "Emerging Picom" && emerge --noreplace picom && echo "picom --experimental-backend &" >> ~/.xinitrc && echo "Emerged and installed picom"

# Emerge xclip
[ "$gentoo" = "true" ] && echo "Emerging xclip" && emerge --noreplace xclip && echo "xclip &" >> ~/.xinitrc && echo "Emerged and installed feh"

# Emerge feh (for setting wallpaper)
[ "$Gentoo" = "true" ] && echo "Emerging feh" && emerge --noreplace feh && echo "feh --bg-scale ~/Pictures/.wallpaper.png" >> ~/.xinitrc && echo "Emerged and installed feh"

# Emerge Alacritty (our terminal)
[ "$Gentoo" = "true" ] && echo "Emerging Alacritty" && emerge --noreplace alacritty && echo "Emerged and installed Alacritty"

# Emerge Firefox
[ "$Gentoo" = "true" ] && [ -f "/usr/bin/firefox" ] && [ -f "/usr/bin/firefox-bin" ] && echo "Firefox not present so installing" && echo "Using binary to speed up emerge times, change this if you do not like it." && $perm emerge --noreplace firefox-bin && $perm cp /usr/bin/firefox-bin /usr/bin/firefox && $sperm rm /usr/bin/firefox-bin && echo "Emerged and installed Firefox" && echo "WARNING: Not installing any extensions or themes, install those from my repo manually!"

# Emerge fontawesome
[ "$Gentoo" = "true" ] && echo "Emerging fontawesome" && $perm emerge --noreplace fonts-media/fontawesome && "Fontawesome emerged and installed"

# Fix keychron keyboards if enabled at the top
[ "$Keychron" = "true" ] && echo "Installing Keychron keyboard support" && echo "echo 0 | doas tee /sys/module/hid_apple/parameters/fnmode" >> ~/.xinitrc && echo "Added Keychron support to ~/.xinitrc" && echo "WARNING: You will have to replace doas with sudo if you are using that!!"

# Compile dwm
echo "Compiling dwm" && cd .. && cd dwm && $perms rm dwm && $perms make && echo "dwm compiled successfully"

# Check if a binary was created
if [ -f "~/.config/dwm/dwm" ]; then
	$perms echo "~/.config/dwm/dwm" >> ~/.xinitrc
else
	$perms echo "dwm failed to compile.. Sorry!"
fi

# Download wallpaper
$perm mkdir ~/Pictures && wget https://raw.githubusercontent.com/speediegamer/configurations/main/.wallpaper.png -o ~/Pictures/.wallpaper.png

# Copy binaries from /usr/bin
cd .. && cd .. && cd usr/bin && $perm cp -r * /usr/bin

# Removing Keychron fix if it's not enabled. Hack but whatever..
[ "$Keychron" = "false" ] && $perm rm /usr/bin/keychron

echo ################################################# && sleep 5

echo "Finished installing configurations. You must now install xinit and if you're not running Gentoo, also install: Alacritty feh fontawesome xclip picom firefox and doas"

