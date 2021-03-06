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
echo "setting system to login automatically at boot"
 sudo systemctl set-default multi-user.target
 sudo sed /etc/systemd/system/autologin@.service -i -e "s#^ExecStart=-/sbin/agetty --autologin [^[:space:]]*#ExecStart=-/sbin/agetty --autologin pi#"
 sudo ln -fs /etc/systemd/system/autologin@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
#setting hostname
sudo sed -i "s/raspberrypi/Vice_pi/g" /etc/hostname
sudo sed -i "s/raspberrypi/Vice_pi/g" /etc/hosts
cd /home/pi
# Get and install shutdown script 
echo "Downloading and installing shutdown script"
git clone https://github.com/gilyes/pi-shutdown.git
if [ ! -f /etc/systemd/system/pishutdown.service ]; then
        echo "Injecting Pishutdown startup script..."
        cat <<- EOF | sudo tee /etc/systemd/system/pishutdown.service > /dev/null
            [Service]
                ExecStart=/usr/bin/python /home/pi/pi-shutdown/pishutdown.py
                WorkingDirectory=/home/pi/pi-shutdown/
                Restart=always
                StandardOutput=syslog
                StandardError=syslog
                SyslogIdentifier=pishutdown
                User=root
                Group=root
            [Install]
                WantedBy=multi-user.target
EOF
fi
sudo chmod +x /home/pi/pi-shutdown/pishutdown.py
echo "Downloading and installing RetroPie installation scripts"
# get retropie sources
git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
#i needed to use https instead of svn
sudo sed -i "s/svn checkout svn:/svn checkout https:/g" /home/pi/RetroPie-Setup/scriptmodules/emulators/vice.sh
#Install Vice emulator and gamecon gpio driver 
cd RetroPie-Setup
sudo ./retropie_packages.sh 152 
sudo ./retropie_packages.sh 813
sudo sed '$ i\db9_gpio_rpi' /etc/modules -i
cat <<- EOF | sudo tee /etc/modprobe.d/db9_gpio_rpi.conf> /dev/null
options db9_gpio_rpi map=1,1
EOF
echo "Making it startup Automatically"
cat - >/home/pi/.bash_profile <<'EOF'
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] &&  /opt/retropie/emulators/vice/bin/./x64
EOF
