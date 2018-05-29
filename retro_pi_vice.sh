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
# gecd
git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
cd Retropie-Setup
sudo ./retropie_packages.sh 152 
sudo ./retropie_packages.sh 813

