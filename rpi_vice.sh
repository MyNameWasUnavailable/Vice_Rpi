#!/bin/bash
echo "Updating system before we start"
sudo apt-get update
sudo apt-get -y upgrade
#Set overscan
sudo sed -i "s/#disable_overscan=1/disable_overscan=1/g" /boot/config.txt
#set timezone
echo "updating Timezone"
sudo ln -fs /usr/share/zoneinfo/Australia/Sydney /etc/localtime
sudo dpkg-reconfigure -f noninteractive tzdata
#Set locale
sudo sed -i '/^#.* en_AU.* /s/^#//' /etc/locale.gen
sudo locale-gen
#Setting Keyboard Layout
echo "Setting keyboard layout"
sudo rm /etc/default/keyboard
cat <<- EOF | sudo tee /etc/default/keyboard> /dev/null
# KEYBOARD CONFIGURATION FILE

# Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="au"
XKBVARIANT=""
XKBOPTIONS=""

BACKSPACE="guess"
EOF
#setting hostname
sudo sed -i "s/raspberrypi/Vice_pi/g" /etc/hostname
echo "Installing window Manager environment"
sudo apt-get install -y --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox

#build vice
sudo apt install autoconf automake build-essential byacc dos2unix flex libavcodec-dev libavformat-dev libgtk2.0-cil-dev libgtkglext1-dev libmp3lame-dev libmpg123-dev libpcap-dev libpulse-dev libreadline-dev libswscale-dev libvte-dev libxaw7-dev subversion texi2html texinfo yasm libgtk3.0-cil-dev xa65 pulseaudio libsdl2-dev 
mkdir -p src
cd src
svn checkout https://svn.code.sf.net/p/vice-emu/code/trunk trunk
cd trunk/vice
./autogen.sh
./configure --enable-sdlui2
make -j4
sudo make install

cat <<- EOF | sudo tee /etc/xdg/openbox/autostart > /dev/null
# Disable any form of screen saver / screen blanking / power management
xset s off
xset s noblank
xset -dpms

# Allow quitting the X server with CTRL-ATL-Backspace
setxkbmap -option terminate:ctrl_alt_bksp

x64
EOF
